# Squadar

Squadar assesses and measures team members' skills — by exam, assessor rating and self-assessment —
ranks each skill on a 1–10 scale, and plots multiple members' skills together on a shared radar chart.
Four roles use it: Administrator, Assessor, Team Member and Viewer. It is specified but not yet built:
a React.js web client and a React Native mobile client over a shared Node.js REST API, a relational
store and a protected asset store.

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
- `DESIGN.md` sets WCAG 2.2 AA for every screen in both themes; treat it as a build requirement, not a
  later pass.
- `UT-10.1`: keep a fixture of 10 fake users at 10 different skill levels usable by every build step.

## Workflow

- Build, test, lint and run commands: TO BE DECIDED — add them here once they exist. Do not invent them.
- Branching, PR, review and release process: TO BE DECIDED.
