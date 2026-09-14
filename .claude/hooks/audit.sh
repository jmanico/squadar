#!/usr/bin/env bash
# PostToolUse hook, all tools.
#
# Appends one JSON line per tool call to .claude/logs/tool-audit.jsonl: timestamp, session ID, tool
# name, and the command or file path. Observe only — never blocks, always exits 0.
#
# Modelled on SEC-LOG-2 (actor, action, target, timestamp) and subject to SEC-LOG-3: it records
# identifiers and paths, never file contents, command output, credentials or tokens. The log is
# append-only in practice and protect-files.sh refuses edits to it (SEC-LOG-4).
#
# This is a development-tool audit trail, not the product's audit trail (NFR-9.6 / SEC-LOG-1), which
# the Assessment component owns.

set -uo pipefail

dir="${CLAUDE_PROJECT_DIR:-.}/.claude/logs"
mkdir -p "$dir" 2>/dev/null || exit 0

cat | python3 -c '
import json, sys, os, datetime

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

ti = d.get("tool_input") or {}
target = (
    ti.get("command")
    or ti.get("file_path")
    or ti.get("path")
    or ti.get("pattern")
    or ti.get("url")
    or ""
)
if len(target) > 500:
    target = target[:500] + "...[truncated]"

entry = {
    "ts": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "session_id": d.get("session_id", ""),
    "tool": d.get("tool_name", ""),
    "target": target,
    "cwd": d.get("cwd", ""),
}

path = os.path.join(sys.argv[1], "tool-audit.jsonl")
try:
    with open(path, "a") as f:
        f.write(json.dumps(entry) + "\n")
except Exception:
    pass
' "$dir" 2>/dev/null

exit 0
