# [REQ-FOUND-010] Establish the npm workspaces monorepo with strict TypeScript and the quality gate

## Metadata

- **ID**: REQ-FOUND-010
- **Title**: Establish the npm workspaces monorepo with strict TypeScript and the quality gate
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Operational
- **Source / Parent**: REQ-FOUND-000; `CLAUDE.md` Workflow

## Requirement

- **Statement**: The repository MUST provide an npm workspaces monorepo containing `api/`, `web/`, `mobile/`, `shared/` and `infra/`, with TypeScript strict mode and root commands for install, build, test, lint, format, typecheck and dev that delegate to the workspaces.
- **Rationale**: `CLAUDE.md` states this layout and command set as the project's working convention, and requires `npm ci`, lint, typecheck, test and build to pass before a pull request merges. No `package.json` exists yet, so nothing else can be built.
- **Assumptions**: The workspace names and the command table in `CLAUDE.md` are the intended ones.
- **Out of Scope**: The CI system that will run the gate (`PQ-9`); any application code; the database product (`PQ-8`).
- **Design Traceability**: N/A — no user-facing surface.
- **Architecture Traceability**: `ARCHITECTURE.md` DR-10 — components are defined by boundary and ownership and may be realized as modules in one deployable; the workspace split reflects that without fixing a topology.
- **Security Traceability**: SEC-SECRET-1, SEC-SECRET-3, DEP-1, DEP-2, DEP-3, DEP-4, DEP-5, DEP-6, DEP-7, DEP-8.

## Scope

- **Applies To**: Multiple
- **Components**: All — this is the repository substrate
- **Interfaces / Operations**: `npm ci`, `npm run build`, `npm test`, `npm run lint`, `npm run format`, `npm run typecheck`, `npm run dev`
- **Actors**: Developers; the CI pipeline
- **Preconditions**: None
- **Data Classification**: Public — configuration only
- **Personal or Regulated Data**: None
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Integrity
- **Control Layers**: Architecture, Supply Chain
- **Threat References**: STRIDE — Tampering; OWASP Top 10:2025 Software and Data Integrity Failures
- **Abuse / Misuse Case**: A dependency resolved from a floating version at build time; a credential committed in a config file; a secret-shaped value embedded in a client bundle.
- **Trust Boundary**: The build boundary — third-party code entering artifacts that run behind the API boundary
- **Untrusted Inputs or Assertions**: Every package and its transitive graph
- **Authoritative Enforcement Point**: The committed lockfile and the root quality-gate commands
- **Independent Verification**: `npm ci` resolves from the lockfile only, so a developer's local resolution cannot differ from CI's (DEP-7)
- **Zero Trust Relevance**: N/A — supply-chain integrity, not resource access

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: `SECURITY.md` DEP-1…DEP-8
- **Mapping Basis**: DEP-1…DEP-8 are the project's dependency policy and govern every package this issue introduces.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a clean checkout, when `npm ci && npm run lint && npm run typecheck && npm test && npm run build` runs from the repository root, then all five commands succeed and each delegates to every workspace that defines the script.
2. **AC-02 — Boundary or failure behavior**: Given a TypeScript file with an implicit `any` or an unchecked null, when `npm run typecheck` runs, then it fails — strict mode is on in every workspace, not only at the root.
3. **AC-03 — Prohibited behavior**: Given `package.json` and the lockfile, when dependency resolution is inspected, then no dependency MUST resolve from a floating range at build or deployment time (DEP-7), and no credential or secret-shaped value MUST appear in any committed configuration file (SEC-SECRET-1).

## Failure Behavior

- **On Invalid Input**: A malformed workspace configuration fails the install with the offending workspace named
- **On Authentication Failure**: N/A
- **On Authorization Failure**: N/A
- **On Security-Decision Failure**: N/A — no runtime security decision
- **On External Dependency Failure**: A registry outage fails `npm ci`; it MUST NOT fall back to a floating resolution (DEP-7)
- **On System Error**: A failed build leaves no partially published artifact
- **Logging / Audit**: `.claude/hooks/audit.sh` records development-tool actions, redacted per SEC-LOG-3
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: A trivial passing test per workspace, so `npm test -w <workspace>` is proven to reach it
- **Integration Tests**: The full root command sequence run end to end from a clean checkout
- **Security Tests**: Secret scan over source and any built bundle (SEC-SECRET-1, SEC-SECRET-3); an assertion that `npm ci` fails when the lockfile is absent or stale (DEP-7)
- **Compliance Tests / Evidence**: N/A
- **Acceptance-Criteria Traceability**: AC-01 by the root sequence test; AC-02 by a fixture file that must fail typecheck; AC-03 by the secret scan and the lockfile assertion
- **Coverage Target**: Set here for the project and enforced from this issue onward; every security-critical decision and error path in later issues carries positive and negative coverage
- **Required Test Environment**: A clean checkout with no `node_modules`

## Dependencies

- **Upstream Requirements**: None
- **Downstream Requirements**: Every other requirement in the project
- **External Dependencies**: The npm registry
- **Dependency Assumptions**: Resolution is reproducible from the committed lockfile (DEP-7)
- **Failure Impact**: Nothing else can be built until this is Verified.

## Implementation Notes

- **Constraints**: TypeScript strict mode in every workspace; root commands delegate rather than duplicate (`CLAUDE.md`)
- **Prohibited Approaches**: Floating versions; a per-workspace lockfile that diverges from the root; secrets in committed configuration
- **Implementation Guidance**: Enable `.claude/hooks/run-tests.sh` with this workspace — `CLAUDE.md` records it as a documented placeholder awaiting exactly this issue. Move the full gate into CI when the CI system is chosen (`PQ-9`).
- **AI Development Guidance**: `CLAUDE.md`; justify every dependency in the pull request against DEP-1…DEP-8
- **Required Human Review**: Architecture reviewer for the layout; security reviewer for the initial dependency set
- **Open Decisions**: None
- **Estimated effort**: 0.5–1 engineer-day; 200–400 changed human-authored lines (excluding the lockfile)
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — well-specified scaffolding against a stated command table, with no product decision to make and no security-sensitive logic.
