#!/usr/bin/env bash
# Stop hook.
#
# Runs the project's test suite so a turn does not end on a red build. Exits 2 with the failure
# output, which is returned to Claude so it can fix the failure rather than stopping.
#
# CLAUDE.md, Workflow: "npm ci, lint, typecheck, test and build must pass before a PR merges" and
# "Every requirement's acceptance criteria land as tests in the same change."

set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

# ---------------------------------------------------------------------------
# TO BE DECIDED — no test command exists yet.
#
# CLAUDE.md specifies `npm test` at the repository root, but no package.json,
# no dependencies and no test runner have been created. Until they exist this
# hook reports and passes.
#
# WHEN THE SUITE EXISTS: delete this block and uncomment the run below.
# ---------------------------------------------------------------------------
if [ ! -f package.json ]; then
  echo "run-tests.sh: test command TO BE DECIDED — no package.json in the repository yet." >&2
  echo "Per CLAUDE.md the command will be 'npm test'; this hook enforces nothing until it exists." >&2
  exit 0
fi

# output=$(npm test 2>&1)
# status=$?
# if [ $status -ne 0 ]; then
#   echo "Test suite failed — the turn cannot end on a red build." >&2
#   echo "$output" | tail -n 100 >&2
#   exit 2
# fi

echo "run-tests.sh: package.json found but the test invocation is still commented out." >&2
echo "Enable the 'npm test' block in this script now that the suite exists." >&2
exit 0
