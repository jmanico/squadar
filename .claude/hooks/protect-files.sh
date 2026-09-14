#!/usr/bin/env bash
# PreToolUse hook, matcher: Edit|Write|MultiEdit
#
# Refuses edits to paths holding material SECURITY.md classifies as not-for-source-control.
# Basis: SEC-SECRET-1 — "Credentials, signing keys, OIDC client secrets, mail-provider credentials,
# database credentials and asset-store credentials MUST NOT appear in source control ... Terraform
# state committed to the repository, logs, error responses or build artifacts."
# Also: SEC-LOG-4 — audit and security log entries MUST be append-only and not modifiable through any
# product interface.
#
# Exit 2 blocks the tool call and returns stderr to Claude.

set -uo pipefail

input=$(cat)

path=$(printf '%s' "$input" | python3 -c '
import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
i = d.get("tool_input") or {}
print(i.get("file_path") or i.get("path") or "")
' 2>/dev/null)

[ -z "$path" ] && exit 0

base=${path##*/}

deny() {
  echo "Blocked by protect-files.sh: $path" >&2
  echo "$1" >&2
  echo "SECURITY.md classifies this as material that must not be written from a tool call." >&2
  exit 2
}

case "$base" in
  .env|.env.*|*.env) deny "SEC-SECRET-1: environment files hold credentials." ;;
  *.pem|*.key|*.p12|*.pfx|*.jks|*.keystore|id_rsa|id_ed25519|id_ecdsa)
    deny "SEC-SECRET-1: key material and credentials must not be in source control." ;;
  *.tfstate|*.tfstate.*|*.tfvars|.terraformrc|terraform.rc)
    deny "SEC-SECRET-1: Terraform state and variable files may carry provisioned secrets." ;;
  credentials|.netrc|.npmrc|.pgpass|.htpasswd)
    deny "SEC-SECRET-1: credential store." ;;
  *.jwk|*.jwks|jwks.json)
    deny "SEC-SECRET-2: JWT signing key material is held by Identity & Access, not the repository." ;;
esac

case "$path" in
  */.ssh/*|.ssh/*|*/.aws/*|.aws/*|*/.gnupg/*|.gnupg/*)
    deny "SEC-SECRET-1: user credential directory." ;;
  */secrets/*|secrets/*|*/.secrets/*)
    deny "SEC-SECRET-1: secret material must live in a secret store, not the repository." ;;
  *audit*.log|*/audit/*|*security*.log)
    deny "SEC-LOG-4: audit and security logs are append-only and not editable." ;;
  */.git/*|.git/*)
    deny "Git internals are not an editable surface." ;;
esac

exit 0
