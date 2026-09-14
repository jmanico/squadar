#!/usr/bin/env bash
# Create the Squadar issue hierarchy on GitHub from the drafts in .planning/github-issues/.
# Idempotent-ish: re-running creates duplicates, so run once. Stops on the first failure.
#
# Requires: gh authenticated (`gh auth login`), with repo scope.
# Sub-issue linking uses the GraphQL addSubIssue mutation, because `gh issue create`
# has no --parent flag as of gh 2.93.

set -euo pipefail

cd "$(dirname "$0")/.."
DIR=.planning/github-issues
REPO="${REPO:-jmanico/squadar}"
MAP="$(mktemp)"   # ID<TAB>number<TAB>url<TAB>nodeid
trap 'echo; echo "Issue map (partial state if this aborted): $MAP"' EXIT

echo "Target repository: $REPO"
gh repo view "$REPO" --json nameWithOwner -q .nameWithOwner >/dev/null

# --- guard: refuse to double-create -------------------------------------------------
if gh issue list --repo "$REPO" --search '"[REQ-EPIC-001]" in:title' --state all --json number -q '.[].number' | grep -q .; then
  echo "ERROR: an issue titled [REQ-EPIC-001] already exists in $REPO. Aborting rather than duplicating." >&2
  exit 1
fi

# --- pass 1: create every issue, bodies still carrying {{ISSUE_URL:*}} placeholders ---
for f in "$DIR"/[0-9]*-REQ-*.md; do
  id=$(basename "$f" .md | sed 's/^[0-9]*-//')
  title=$(head -1 "$f" | sed 's/^# //')
  echo "creating $id ..."
  url=$(gh issue create --repo "$REPO" --title "$title" --body-file "$f")
  num=${url##*/}
  node=$(gh issue view "$num" --repo "$REPO" --json id -q .id)
  printf '%s\t%s\t%s\t%s\n' "$id" "$num" "$url" "$node" >> "$MAP"
done

# --- pass 2: replace {{ISSUE_URL:<ID>}} placeholders and update the bodies ------------
echo "resolving task-list placeholders ..."
while IFS=$'\t' read -r id num url node; do
  f=$(ls "$DIR"/*-"$id".md)
  grep -q '{{ISSUE_URL:' "$f" || continue
  body=$(cat "$f")
  while IFS=$'\t' read -r rid rnum rurl rnode; do
    body=${body//\{\{ISSUE_URL:$rid\}\}/$rurl}
  done < "$MAP"
  printf '%s\n' "$body" | gh issue edit "$num" --repo "$REPO" --body-file - >/dev/null
  echo "  updated $id (#$num)"
done < "$MAP"

# --- pass 3: link children to parents as GitHub sub-issues ----------------------------
link() {  # link <parent-id> <child-id>
  p=$(awk -v k="$1" -F'\t' '$1==k{print $4}' "$MAP")
  c=$(awk -v k="$2" -F'\t' '$1==k{print $4}' "$MAP")
  gh api graphql -f query='mutation($p:ID!,$c:ID!){addSubIssue(input:{issueId:$p,subIssueId:$c}){clientMutationId}}' \
    -f p="$p" -f c="$c" >/dev/null && echo "  $1 <- $2"
}

echo "linking sub-issues ..."
for ws in REQ-FOUND-000 REQ-UIKIT-000 REQ-AUTH-000 REQ-ROSTER-000 REQ-SKILL-000 \
          REQ-SCORE-000 REQ-EXAM-000 REQ-CHART-000 REQ-PORT-000 REQ-MOBILE-000 REQ-INFRA-000; do
  link REQ-EPIC-001 "$ws"
done
while IFS=$'\t' read -r id num url node; do
  case "$id" in
    REQ-EPIC-001|*-000) continue ;;
  esac
  link "${id%-*}-000" "$id"
done < "$MAP"

epic=$(awk -F'\t' '$1=="REQ-EPIC-001"{print $3}' "$MAP")
echo
echo "Epic:    $epic"
echo "Created: $(wc -l < "$MAP") issues"
echo "Map:     $MAP"
trap - EXIT
