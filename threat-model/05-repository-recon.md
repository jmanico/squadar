# 05 — Repository Threat Reconnaissance

**Target:** `squadar` @ `6441881`
**Date:** 2026-09-14
**Mode:** Autonomous, non-interactive
**Companion data:** `05-repository-recon.cdx.json`

---

## Headline finding

**The repository contains no application code.** Every tracked file is a specification, a design
artifact, or Claude Code tooling. There is no `package.json`, no `api/`, `web/`, `mobile/`, `shared/`
or `infra/` workspace, no route table, no schema, no Dockerfile, no Terraform. `SECURITY.md` states
this itself: *"No implementation exists yet; every rule here is prospective and nothing below asserts
that any control has been built, tested or assessed."*

Consequently phases 1–7 of repository reconnaissance yield **evidence of intent, not evidence of
implementation**. No control in this threat model may be recorded as *Verified in code*. Every control
is **Specified — Not Implemented**, and the entire threat inventory describes risk that will be
introduced when the code is written, not risk currently running.

This is the most valuable possible moment to threat model, and also the moment at which severity
ratings mean something different than usual — see *Scoring convention* below.

---

## Phase 1 — Technology stack

Extracted from `ARCHITECTURE.md` and `SECURITY.md`; **no manifest, lockfile or version is present in
the repository**, so every entry is a stated intention with no version pinned.

| Layer | Technology | Version | Source of fact |
| --- | --- | --- | --- |
| Server runtime | Node.js | UNKNOWN | `ARCHITECTURE.md` Required Inputs |
| Server framework | — | TO BE DECIDED | `SECURITY.md` `{{BACKEND_FRAMEWORK_PROMPT}}` |
| Web client | React.js | UNKNOWN | `ARCHITECTURE.md` |
| Mobile client | React Native | UNKNOWN | `ARCHITECTURE.md` |
| Shared validation | TypeScript, strict | — | `CLAUDE.md` Workflow |
| Persistence | Relational, 3NF | Product TO BE DECIDED | `ARCHITECTURE.md` Relational Data Store |
| Large binary assets | "Protected folders" outside the DB | TO BE DECIDED | `ARCHITECTURE.md` Protected Asset Store |
| Identity | Passkey (WebAuthn) + password + OIDC | Provider UNKNOWN | `ARCHITECTURE.md`, `SECURITY.md` |
| Session | JWT | Split/transport/lifetime TO BE DECIDED | `SECURITY.md` `SQ-5` |
| IaC | Terraform | UNKNOWN | `ARCHITECTURE.md` |
| Cloud provider | — | UNKNOWN (`SQ-8`) | `SECURITY.md` |
| CI system | — | UNKNOWN (`SQ-8`) | `SECURITY.md` |
| Chart rendering library | — | TO BE DECIDED | `ARCHITECTURE.md` Web Client open decisions |

**Dependency posture:** zero dependencies exist. `DEP-1`…`DEP-8` in `SECURITY.md` are a written
policy with nothing yet to apply to. There is no lockfile, so `DEP-7` (frozen resolution) is
unverifiable, and no vulnerability scanning configuration exists anywhere in the repository.

## Phase 2 — Entry point enumeration

No routes exist. Entry points below are **derived from requirements**, not read from code, and are
listed because they are the surface the first PR will create. Authentication is universal by
`FR-1.1` / `SEC-AUTHN-1`: there is no unauthenticated product surface.

| Derived entry point | Requirement | Authn | Authorization model |
| --- | --- | --- | --- |
| Sign-in (passkey / password) | FR-1.1 | none (is the boundary) | — |
| OIDC callback | `ARCHITECTURE.md` flow 1 | none (is the boundary) | issuer/audience/nonce checks |
| Account-access email link | FR-5.5, `SEC-AUTHN-8` | link token | single-use, recipient-bound |
| Exam invitation link | FR-5.5 | link token | single-use, recipient-bound |
| Chart dataset request | FR-7.1–FR-7.11 | required | role + shared-team membership |
| Score table / ranked list | FR-6.2, FR-6.3 | required | role + team scope |
| Score write (assessor rating) | FR-5.2, FR-1.5 | required | Assessor limited to assigned teams |
| Score write (self-assessment) | FR-5.2 | required | self only |
| Exam fetch (questions) | FR-5.6 | required | assigned attempt only; answer keys excluded |
| Exam submit | FR-5.6–FR-5.8 | required | assigned, uncompleted attempt only |
| Exam definition CRUD (with answer keys) | FR-5.4 | required | Administrator |
| Exam assignment | FR-5.5 | required | Assessor or Administrator |
| Skill catalog CRUD | FR-3.2 | required | Administrator |
| Team member CRUD / deactivate | FR-2.2 | required | Administrator |
| Team create / save / reopen | FR-2.4 | required | role-dependent |
| Account and role CRUD | FR-1.3 | required | Administrator only |
| Bulk import (delimited file upload) | FR-8.2 | required | Administrator |
| Self export (machine-readable) | FR-8.3 | required | self only |
| Personal-data deletion | FR-8.4 | required | Administrator |
| Audit trail read | NFR-9.6 | required | Administrator only |
| Protected asset read (exam media) | DR-9 | required | live per-asset decision |

**File upload/download interfaces:** bulk import (in), self export (out), exam media (both).
**Background work / cron / queues:** none defined. Whether bulk import runs asynchronously is
TO BE DECIDED (`SQ-9`); whether mail sending is queued is TO BE DECIDED.

## Phase 3 — Data store analysis

No schema, migration, model or ORM configuration exists. Two stores are named:

**Relational Data Store** — third normal form. Sensitive fields derived from requirements: user
records and credentials (password hashes, passkey public-key material, session state), team member
identity, skill scores (1–10) and full score history, assessment records with method and assessor,
exam definitions, **exam questions and answer keys**, exam attempts, and audit entries. Encryption at
rest is specified (`SEC-DATA-1`) but is PROVISIONAL with mechanism and key management TO BE DECIDED.
Retention is undefined (`SEC-DATA-6`, pending `SQ-1`). Deletion semantics are undecided (`SQ-6`).

**Protected Asset Store** — large binaries (exam media). Technology and access-grant mechanism
TO BE DECIDED. The intended invariant is `DR-9`/`SEC-BOUND-4`: possession of a reference is not
entitlement.

**Sensitivity classification.** Personal performance data about identifiable individuals, used in a
context that plausibly influences employment and staffing decisions. `REQUIREMENTS.md` asserts no
special-category or regulated data; `SECURITY.md` records that the security notes nevertheless invoke
GDPR and CCPA. **These two statements conflict and the conflict is unresolved (`SQ-1`).**

## Phase 4 — Authentication and authorization architecture

Specified, not built. Passkey/password + OIDC handled solely by Identity & Access (`SEC-AUTHN-2`);
JWT sessions (`SEC-SESSION-1`); ABAC over four attributes — role, an Assessor's assigned teams, the
member a user corresponds to, shared-team membership (`SEC-AUTHZ-2`). Enforcement is intended to sit
at the REST API as the sole enforcement point (`SEC-BOUND-1`, DR-1).

**Undecided and security-material:** session transport and CSRF exposure (`SQ-5`); revocation
mechanism (`SEC-SESSION-3`); whether the OIDC provider may assert role (`SQ-10`); passkey recovery
path (`SQ-7`); assurance level per role (`SQ-3`); whether ABAC supplements or replaces the
single-role model (`SQ-2`).

**No endpoint currently lacks authorization enforcement, because no endpoint exists.** The finding
to carry forward is that the authorization matrix (4 roles × ~22 entry points) has been described in
prose but never expressed as a table, a policy, or a test fixture.

## Phase 5 — Security controls inventory

Forty-eight `SEC-*` rules and eight `DEP-*` rules are written in `SECURITY.md`, each with a stated
verification method. **Zero are implemented. Zero are tested.** `SECURITY.md` self-classifies each as
CONFIRMED (traceable to a requirement) or PROVISIONAL (a safe default chosen there) — that axis
describes provenance, not implementation status.

Controls actually present *in the repository today* are development-time only:

| Present control | Mechanism | Assessment |
| --- | --- | --- |
| Secret/state write blocking | `.claude/hooks/protect-files.sh` | Blocks `Edit`/`Write` to credential- and state-shaped paths; traces to `SEC-SECRET-1`, `SEC-LOG-4` |
| Dangerous-command blocking | `.claude/hooks/block-dangerous.sh` | Blocks piped-in code, destructive shell/git/privilege/infra commands |
| Tool audit trail | `.claude/hooks/audit.sh` → `.claude/logs/tool-audit.jsonl` | Modelled on `SEC-LOG-2`, redacted per `SEC-LOG-3`; log path is git-ignored |
| Permission deny-list | `.claude/settings.json` | Denies reads of `.env*`, `~/.ssh`, `~/.aws`, `*.pem`, `*.key`; denies `sudo`, `curl`, `wget` |
| Sandbox | `.claude/settings.json` `sandbox.enabled`, `failIfUnavailable`, `allowUnsandboxedCommands: false` | Enforced per Bash call |
| Secret hygiene in VCS | `.gitignore` | Ignores `.env`, `.env.*`, `.claude/logs/`, `.claude/settings.local.json` |
| Test gate | `.claude/hooks/run-tests.sh` | **Documented placeholder — no runner, no `package.json`, no CI.** Does not gate anything |

No CSP, no CORS configuration, no rate limiting, no security headers, no secret scanner, no
dependency scanner, and no CI pipeline exist, because no deployable exists.

## Phase 6 — Deployment and infrastructure analysis

**Nothing to analyze.** No Dockerfile, no compose file, no Kubernetes manifest, no Terraform, no
pipeline definition. Terraform is the stated intent; the cloud provider, CI system, runtime topology,
state backend and artifact registry are all UNKNOWN (`SQ-8`). `SECURITY.md` notes the release process
is TO BE DECIDED for the same reason.

Because no infrastructure exists, `SEC-CICD-1`…`SEC-CICD-6` are unenforced by construction, including
`SEC-CICD-4` (protected Terraform state backend) — the `.gitignore` does **not** currently ignore
`*.tfstate`, `*.tfstate.*` or `.terraform/`, which is a gap to close before the first Terraform file
lands. `protect-files.sh` blocks tool-driven writes to state-shaped paths, but a developer working
outside Claude Code is not covered.

## Phase 7 — AI/ML component analysis

**No AI/ML component exists in the product.** There is no model serving, no embedding generation, no
vector store and no RAG pipeline in `REQUIREMENTS.md` or `ARCHITECTURE.md`, so MITRE ATLAS and the
OWASP ML Top 10 are out of scope for the product.

One AI-adjacent surface exists in the **development** environment, not the product: `.claude/`
configures an LLM coding agent whose instructions are read from the specification documents at
runtime. The specification documents are therefore an instruction channel for that agent, and the
`.claude/logs/tool-audit.jsonl` file records its activity. This is recorded as a single
low-severity development-boundary threat (`T-31`) and is explicitly out of the product's trust
boundary set.

## Phase 8 — Trust boundary identification

Six boundaries, all stated in `SECURITY.md` *Public interfaces and trust boundaries* and
`ARCHITECTURE.md`:

| ID | Boundary | Crossing controls specified | Implemented |
| --- | --- | --- | --- |
| `TB-1` | Web/Mobile Client → REST API | `SEC-BOUND-1`, `SEC-BOUND-2`, `SEC-AUTHN-1`, `SEC-SESSION-1`, `SEC-AUTHZ-1`…`8`, `SEC-INPUT-1`, `SEC-HTTP-1`…`7` | No |
| `TB-2` | Identity & Access ↔ OIDC provider | `SEC-AUTHN-5`, `SEC-EXT-1`, `SEC-EXT-2` | No |
| `TB-3` | REST API → Protected Asset Store | `SEC-BOUND-4`, `SEC-DATA-1`, DR-9 | No |
| `TB-4` | Domain components → Relational Data Store | `SEC-INPUT-6`, `SEC-DATA-1`, `SEC-BIZ-2` | No |
| `TB-5` | Outbound Notification → mail provider | `SEC-EXT-1`, `SEC-EXT-3`, `SEC-AUTHN-8` | No |
| `TB-6` | Administrator file → Bulk Import ingest | `SEC-INPUT-4`, `SEC-INPUT-5`, `SEC-AUTHZ-4` | No |

A seventh, **`TB-7` Developer workstation → repository**, exists today and is the only boundary with
any live control (the `.claude/` hooks). It is a development boundary, not a product one.

**Gaps at boundary crossings:** every crossing is a gap in the implementation sense. Two are gaps in
the *specification* sense as well: `TB-3`'s access-grant mechanism is undefined, so `SEC-BOUND-4`
cannot yet be tested; and `TB-1`'s session transport is undecided, so `SEC-HTTP-3` (CSRF) is
conditional and currently unresolvable.

---

## Scoring convention used downstream

Because no code exists, a conventional "exploitable today" severity would be *zero* for every finding
and the model would be useless. Severities in `07` and `10` therefore rate **the risk the design
carries into implementation**: the impact if the threat is realized, weighted by how likely it is to
be built wrong given what the specifications leave undecided. A Critical here means *this will cause
a serious breach unless a specific control is deliberately built and tested*, not *this is currently
exploitable*. Every "Existing control" is recorded as **Specified — Not Implemented**, and no
finding in this model is evidence of a running vulnerability.

## Assumptions made during reconnaissance

1. The monorepo layout in `CLAUDE.md` (`api/`, `web/`, `mobile/`, `shared/`, `infra/`) describes the
   intended structure; none of it exists yet.
2. Exam media exists, following the `ARCHITECTURE.md` ASSUMPTION drawn from the "movie files" note.
   If exams carry no media, `TB-3` and the Protected Asset Store drop out of scope entirely.
3. The four roles in `REQUIREMENTS.md` are marked **(assumed)** at source; the whole authorization
   model rests on them and `OQ-1` may still change `FR-1.4`.
4. "Enterprise scale" is taken as the stated NFR-9.3 figures — 1,000 team members, 100 skills.
