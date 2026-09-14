---
description: Implement one requirement issue end to end — plan, test, implement, audit, PR
argument-hint: <issue number or URL>
---

Implement issue $1 end to end. One requirement per pull request (`CLAUDE.md`).

1. **Read the issue.** `gh issue view $1`. It follows `REQUIREMENT_TEMPLATE.md`, so take the
   Statement, Scope, Acceptance Criteria, Failure Behavior and Test Strategy as given. If it does not
   follow the template, stop and say so — do not implement an unstructured issue.
2. **Read only what it cites.** Open the `FR-*`/`NFR-*`, `DR-*` and `SEC-*` IDs the issue names, in
   their owning documents. Do not read the specs wholesale.
3. **Plan.** State the components you will touch, using the names from `ARCHITECTURE.md`, and the
   enforcement point for each rule. If the issue depends on something the specs mark `TO BE DECIDED`,
   `UNKNOWN`, `OQ-*` or `SQ-*`, stop and ask rather than deciding it here.
4. **Tests first.** Turn every `AC-*` acceptance criterion into a test before writing implementation
   code, including the boundary, failure and prohibited-behavior criteria and the negative
   authorization cases the issue's Test Strategy lists. Run them and confirm they fail for the right
   reason.
5. **Implement** until those tests pass, and no further. Nothing the issue does not ask for.
6. **Review.** Run `spec-auditor` and `security-reviewer` on `git diff main...HEAD`, in parallel.
   Address every blocking finding and re-run. Report concerns you chose not to act on, with the reason.
7. **Pull request.** Branch named for the issue, squash-ready, description linking the issue by number
   and naming the IDs the change satisfies. Justify any new dependency per `DEP-2`. Flag in the
   description if the change touches a trust boundary, so it gets the human security review
   `CLAUDE.md` requires.

Do not open the pull request while a blocking finding stands or a test is failing.
