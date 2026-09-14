# Squadar

Squadar is specified but not yet built. What it does and for whom is in `REQUIREMENTS.md`; how it is
built is in `ARCHITECTURE.md`. This file states only how to work in this repository.

## Specification ownership

These documents are the source of truth. Each owns one domain; read the one your change touches rather
than all of them, and do not restate their content elsewhere.

| File | Owns | Read before |
| --- | --- | --- |
| `REQUIREMENTS.md` | WHAT the system does — actors, workflows, FR/NFR IDs, open questions | changing observable behavior |
| `DESIGN.md` | The design language — tokens, type scale, layout, components, accessibility | any UI work |
| `style-guide.html` | The rendered reference implementation of `DESIGN.md` | any UI work, alongside `DESIGN.md` |
| `ARCHITECTURE.md` | Components, trust boundaries, data flow, dependency rules DR-1…DR-10 | structural or cross-component changes |
| `SECURITY.md` | Threat model and security rules (`SEC-*`, `DEP-*`) | auth, sessions, input handling, data protection, logging, dependencies, or any trust boundary |
| `REQUIREMENT_TEMPLATE.md` | The required structure of a requirement | writing a GitHub issue |

## Rules

- Every new GitHub issue MUST follow `REQUIREMENT_TEMPLATE.md` in full, so each issue is a structured,
  independently testable requirement with acceptance criteria and traceability.
- Cite the governing IDs in code comments, commit messages and PR descriptions where a change
  implements a rule — `FR-`, `NFR-`, `DR-`, `SEC-`, `DEP-`, `OQ-`, `SQ-`.
- A fact belongs to exactly one document. When work requires a decision the specs do not make, change
  the owning document in the same change rather than encoding the decision only in code.
- Items marked `UNKNOWN`, `TO BE DECIDED`, `(assumed)`, `OQ-*` or `SQ-*` are unresolved. Do not silently
  resolve one: implement against the stated assumption and say which you relied on, or ask.
- A change to `DESIGN.md` and the matching change to `style-guide.html` land in the same commit.
- The accessibility conformance target `DESIGN.md` sets is a build requirement, not a later pass: it
  lands with the screen, not after it.
- Keep the `UT-10.1` fixture usable by every build step; `SEC-DATA-5` governs what may be in it.

## Workflow

Chosen here, not stated by the specs. An npm workspaces monorepo — `api/` (Node.js), `web/` (React),
`mobile/` (React Native), `shared/` (types and validation used by all three), `infra/` (Terraform).
Commands run from the repository root and delegate to the workspace.

| Task | Command |
| --- | --- |
| Install | `npm ci` |
| Build | `npm run build` |
| Test | `npm test` — `npm test -w api` for one workspace |
| Single test | `npm test -w api -- <path-or-name-pattern>` |
| Lint and format | `npm run lint` / `npm run format` |
| Types | `npm run typecheck` |
| Run locally | `npm run dev` |

- TypeScript everywhere, strict mode. Validation schemas live in `shared/` and are applied server-side
  at the API boundary; the clients may reuse them only within the limits `DR-1` sets.
- Every requirement's acceptance criteria land as tests in the same change, including the negative and
  authorization cases `REQUIREMENT_TEMPLATE.md` requires under Test Strategy.
- `npm ci`, lint, typecheck, test and build must pass before a PR merges.
- Work on a branch off `main` named for the issue (`req-auth-001-session-lifetime`); never commit to
  `main` directly. One requirement per PR, PR description linking the issue and naming the `FR-`/`SEC-`
  IDs it satisfies, squash merge, delete the branch.
- Every new dependency is justified in the PR description and checked against `DEP-1`…`DEP-8` in
  `SECURITY.md` before it is added.
- Changes to auth, sessions, authorization, input handling, data protection or any trust boundary need
  a human security review before merge.
- Release process: TO BE DECIDED — no deployment target exists yet (`SQ-8`).

## Enforcement

`.claude/` mechanizes the rules above where it can. Each hook traces to a rule in an owning document
and reads that document at runtime; none of them restates a requirement, a security rule or an
architecture decision.

| Rule | Mechanism |
| --- | --- |
| No credential, key or Terraform state written from a tool call (`SEC-SECRET-1`, `SEC-SECRET-2`) | `hooks/protect-files.sh`; `permissions.deny` in `settings.json` |
| Audit and security logs are append-only (`SEC-LOG-4`) | `hooks/protect-files.sh` |
| Development-tool audit trail, modelled on `SEC-LOG-2` and redacted per `SEC-LOG-3` | `hooks/audit.sh` |
| Code enters this project reviewed, never piped in (`SEC-SECRET-1`, `DEP-*`) | `hooks/block-dangerous.sh` |
| Destructive shell, git, privilege and infrastructure commands | `hooks/block-dangerous.sh` — operational safety chosen here, not derived from a specification |
| A change is audited against the specs and `SEC-*`/`DEP-*` before a PR | `agents/spec-auditor.md`, `agents/security-reviewer.md`, invoked by `commands/next-issue.md` |
| Issues follow `REQUIREMENT_TEMPLATE.md`; acceptance criteria land as tests first | `commands/next-issue.md` steps 1 and 4 |

Not mechanically enforced, and why:

- **`npm ci`, lint, typecheck, test and build pass before merge.** `hooks/run-tests.sh` is a documented
  placeholder: no `package.json`, runner or CI system exists yet. Enable it with the first workspace,
  and move the full gate into CI when the CI system is chosen (`SQ-8`).
- **Never commit to `main`; `DESIGN.md` and `style-guide.html` land in the same commit.** Both are
  checkable in a `PreToolUse` hook on `git commit`, but no such hook exists yet. Until one does, these
  hold by convention and at review.
- **Human security review for changes to auth, sessions, authorization, input handling, data protection
  or any trust boundary.** A human gate by definition; `agents/security-reviewer.md` prepares it but
  does not replace it.
- **A fact belongs to exactly one document.** Judgement, not a pattern — `agents/spec-auditor.md`
  reports duplication it sees, but nothing blocks on it.
