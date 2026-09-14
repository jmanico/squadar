# [REQ-FOUND-000] Foundation: workspaces, shared validation and test fixture

## Metadata

- **ID**: REQ-FOUND-000
- **Title**: Foundation: workspaces, shared validation and test fixture
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Operational
- **Source / Parent**: REQ-EPIC-001; `CLAUDE.md` Workflow; `REQUIREMENTS.md` UT-10.1; `ARCHITECTURE.md` DR-1

## Requirement

- **Statement**: The repository MUST provide the workspace structure, the shared server-applied validation schemas and the `UT-10.1` test fixture that every other workstream builds on; delivery is the sum of its children.
- **Rationale**: `CLAUDE.md` chooses an npm workspaces monorepo and requires lint, typecheck, test and build to pass before merge, but no `package.json` exists yet. `UT-10.1` requires a fixture usable by every build step, and `DR-1` requires one server-side validation source.
- **Assumptions**: The workspace layout stated in `CLAUDE.md` (`api/`, `web/`, `mobile/`, `shared/`, `infra/`) is the intended one.
- **Out of Scope**: Database product selection and schema (`PQ-8`); CI system (`PQ-9`, delivered under REQ-INFRA-000).
- **Design Traceability**: N/A — this workstream ships no user-facing surface.
- **Architecture Traceability**: `ARCHITECTURE.md` DR-1, DR-2, DR-10; component boundaries as module boundaries.
- **Security Traceability**: SEC-INPUT-1, SEC-INPUT-2, SEC-SECRET-1, SEC-SECRET-3, SEC-DATA-5, DEP-1…DEP-8.

## Scope

- **Applies To**: Multiple
- **Components**: All — the shared substrate beneath Web Client, Mobile Client, REST API and the domain components
- **Interfaces / Operations**: Repository build, lint, typecheck and test commands; the `shared/` schema module; the seed fixture
- **Actors**: Developers and the CI pipeline
- **Preconditions**: None
- **Data Classification**: Internal
- **Personal or Regulated Data**: None — the fixture is synthetic by SEC-DATA-5
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Integrity
- **Control Layers**: Architecture, Input Validation, Supply Chain
- **Threat References**: STRIDE — Tampering (supply chain), Information Disclosure (secrets and real data in fixtures)
- **Abuse / Misuse Case**: A dependency with an unvetted transitive tree, a secret committed to source, or production personal data copied into a seed fixture.
- **Trust Boundary**: The build boundary — source and dependencies entering the artifact that runs behind the API boundary
- **Untrusted Inputs or Assertions**: Third-party packages and their transitive graph
- **Authoritative Enforcement Point**: The repository's committed lockfile, CI checks and `.claude/hooks/protect-files.sh`
- **Independent Verification**: Lockfile-frozen installs; secret scanning independent of the author's local run
- **Zero Trust Relevance**: N/A — this is supply-chain integrity, not resource access

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no verified control mapping at workstream level
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: `SECURITY.md` DEP-1…DEP-8 govern every dependency added under this workstream
- **Mapping Basis**: DEP-1…DEP-8 are the project's own dependency policy and apply directly to the work this workstream does.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given the children below are Verified, when `npm ci && npm run lint && npm run typecheck && npm test && npm run build` runs from the repository root, then all five succeed.
2. **AC-02 — Boundary or failure behavior**: Given a dependency added without justification against DEP-1…DEP-8, when the pull request is reviewed, then it is refused.
3. **AC-03 — Prohibited behavior**: Given the `UT-10.1` fixture, when it is inspected, then it MUST NOT contain any real person's identity or scores (SEC-DATA-5).

## Failure Behavior

- **On Invalid Input**: N/A
- **On Authentication Failure**: N/A
- **On Authorization Failure**: N/A
- **On Security-Decision Failure**: A failing secret scan or dependency check blocks the merge (SEC-CICD-6)
- **On External Dependency Failure**: A registry outage fails the build; it MUST NOT fall back to floating resolution (DEP-7)
- **On System Error**: N/A
- **Logging / Audit**: `.claude/hooks/audit.sh` records development-tool actions, redacted per SEC-LOG-3
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Delivered by the children — the shared schemas carry their own
- **Integration Tests**: A smoke test that each workspace builds and its tests run from the root
- **Security Tests**: Secret scan over source and built bundles (SEC-SECRET-1, SEC-SECRET-3); fixture inspection (SEC-DATA-5)
- **Compliance Tests / Evidence**: N/A
- **Acceptance-Criteria Traceability**: AC-01 by the root command sequence in CI; AC-02 by pull-request review; AC-03 by the fixture test in REQ-FOUND-030
- **Coverage Target**: Set here for the whole project and enforced from the first workspace
- **Required Test Environment**: None beyond the repository

## Dependencies

- **Upstream Requirements**: None
- **Downstream Requirements**: Every other workstream
- **Child Requirements**:
  - [ ] {{ISSUE_URL:REQ-FOUND-010}} — Establish the npm workspaces monorepo with strict TypeScript and the quality gate
  - [ ] {{ISSUE_URL:REQ-FOUND-020}} — Shared validation schemas applied server-side at the API boundary
  - [ ] {{ISSUE_URL:REQ-FOUND-030}} — Synthetic ten-member, ten-skill test fixture
- **External Dependencies**: The npm registry
- **Dependency Assumptions**: Resolution is reproducible from a committed lockfile (DEP-7)
- **Failure Impact**: No workstream can start until REQ-FOUND-010 is Verified.

## Implementation Notes

- **Constraints**: TypeScript strict mode; commands run from the repository root and delegate to the workspace (`CLAUDE.md`)
- **Prohibited Approaches**: No floating dependency versions; no secret in source or in a client bundle; no production data in a fixture
- **Implementation Guidance**: `.claude/hooks/run-tests.sh` is a documented placeholder — enable it with the first workspace
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` for every dependency addition
- **Required Human Review**: Architecture reviewer for the workspace layout; security reviewer for the initial dependency set
- **Open Decisions**: None blocking
