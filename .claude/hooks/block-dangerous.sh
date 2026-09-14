#!/usr/bin/env bash
# PreToolUse hook, matcher: Bash
#
# Refuses destructive shell strings. This deliberately overlaps the deny list in
# .claude/settings.json: the deny rules stop the tool call by pattern, this hook inspects the shell
# string that a compound or quoted command can slip past one.
#
# Exit 2 blocks the tool call and returns stderr to Claude.

set -uo pipefail

input=$(cat)

cmd=$(printf '%s' "$input" | python3 -c '
import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
print((d.get("tool_input") or {}).get("command") or "")
' 2>/dev/null)

[ -z "$cmd" ] && exit 0

deny() {
  echo "Blocked by block-dangerous.sh." >&2
  echo "Reason: $1" >&2
  echo "Command: $cmd" >&2
  exit 2
}

# Destructive filesystem removal
case "$cmd" in
  *"rm -rf /"*|*"rm -fr /"*|*"rm -rf /*"*|*"rm -rf ~"*|*"rm -rf \$HOME"*)
    deny "recursive delete of a root or home path" ;;
  *"rm -rf ."*|*"rm -rf .."*|*"rm -rf *"*)
    deny "unbounded recursive delete" ;;
esac

# Irrecoverable git operations
case "$cmd" in
  *"git reset --hard"*)     deny "discards uncommitted work irrecoverably" ;;
  *"git clean -"*[fd]*)     deny "deletes untracked files irrecoverably" ;;
  *"git push"*--force*|*"git push"*" -f"*)
                            deny "force push rewrites published history" ;;
  *"git checkout ."*|*"git restore ."*)
                            deny "discards all working-tree changes" ;;
  *"git branch -D"*)        deny "deletes an unmerged branch" ;;
  *"git filter-branch"*|*"git filter-repo"*)
                            deny "rewrites repository history" ;;
esac

# Privilege, permissions, and disk
case "$cmd" in
  *sudo*|*doas*)            deny "privilege escalation" ;;
  *"chmod 777"*|*"chmod -R 777"*)
                            deny "world-writable permissions" ;;
  *"chown -R"*)             deny "recursive ownership change" ;;
  *"mkfs"*|*"dd if="*"of=/dev/"*|*"> /dev/sd"*)
                            deny "writes directly to a device" ;;
esac

# Fetch-and-execute — SEC-SECRET-1 and DEP-* mean code enters this project reviewed, never piped in
case "$cmd" in
  *curl*\|*sh*|*curl*\|*bash*|*wget*\|*sh*|*wget*\|*bash*)
    deny "piping a downloaded script into a shell" ;;
esac

# Publishing and remote state
case "$cmd" in
  *"npm publish"*|*"npm unpublish"*)
    deny "publishes or withdraws a package" ;;
  *"terraform destroy"*|*"terraform apply"*"-auto-approve"*)
    deny "unreviewed change to provisioned infrastructure" ;;
esac

# Exfiltration of the very material protect-files.sh guards (SEC-SECRET-1)
case "$cmd" in
  *".env"*curl*|*".env"*nc\ *|*"id_rsa"*curl*|*".pem"*curl*)
    deny "sends credential material to a remote host" ;;
esac

exit 0
