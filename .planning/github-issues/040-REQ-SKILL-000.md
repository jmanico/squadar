# [REQ-SKILL-000] Skill catalog

## Metadata

- **ID**: REQ-SKILL-000
- **Title**: Skill catalog
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-EPIC-001; `REQUIREMENTS.md` FR-3.1–FR-3.4, FR-7.5; `ARCHITECTURE.md` Skill Catalog

## Requirement

- **Statement**: The Skill Catalog component MUST own a single system-wide catalog of named skills, reject duplicate active names, retire skills without losing their history, and supply the axis candidates for chart configuration; delivery is the sum of its children.
- **Rationale**: FR-3.1 requires one catalog against which every member is assessed, so scores are comparable across members and charts share one axis vocabulary (FR-7.4).
- **Assumptions**: FR-3.1 is marked **(assumed)**; a single system-wide catalog rather than per-team catalogs stands until that assumption is revisited.
- **Out of Scope**: Skill grouping or categorization — `UNKNOWN` in `ARCHITECTURE.md`. Scores against a skill, which Assessment owns.
- **Design Traceability**: `DESIGN.md` — Components (Inputs, persistent visible labels, required-field marking); Form feedback and errors.
- **Architecture Traceability**: `ARCHITECTURE.md` Skill Catalog; DR-3, DR-4.
- **Security Traceability**: SEC-AUTHZ-1, SEC-AUTHZ-5, SEC-AUTHZ-6, SEC-BIZ-3, SEC-INPUT-1, SEC-INPUT-6, SEC-RENDER-1.

## Scope

- **Applies To**: Multiple
- **Components**: Skill Catalog; REST API; Web Client
- **Interfaces / Operations**: Skill add, rename, retire; active-skill list; axis candidate list
- **Actors**: Administrator (write), all roles (read)
- **Preconditions**: The caller is authenticated and their role is resolved
- **Data Classification**: Internal
- **Personal or Regulated Data**: None
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Integrity, Authorization
- **Control Layers**: Authorization, Input Validation, Business-Rule Validation, Output Encoding
- **Threat References**: STRIDE — Tampering; OWASP Top 10:2025 Broken Access Control
- **Abuse / Misuse Case**: A non-Administrator renaming or retiring a skill; a duplicate active name splitting a member's history across two skills; markup in a skill name reaching a chart axis label.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Skill names, skill identifiers, sort and filter parameters on the catalog list
- **Authoritative Enforcement Point**: REST API for authorization; Skill Catalog for uniqueness and retirement rules
- **Independent Verification**: Uniqueness is enforced in the Relational Data Store as well as in application logic
- **Zero Trust Relevance**: N/A — catalog reads are permitted to every authenticated role

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: N/A
- **Mapping Basis**: No standard mapping has been verified for this workstream; the governing rules are the project's own SEC-* identifiers.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an Administrator, when they add a skill with a name not matching any active skill, then the skill is created and appears in the active catalog and in the axis candidate list (FR-3.2, FR-7.5).
2. **AC-02 — Boundary or failure behavior**: Given an existing active skill named "TypeScript", when an Administrator submits a second skill with that name, then the request is rejected with a stated reason and no second record is created (FR-3.3).
3. **AC-03 — Prohibited behavior**: Given a retired skill, when a new assessment is attempted against it, then the assessment MUST NOT be recorded, while existing scores for that skill remain retrievable (FR-3.4, SEC-BIZ-3).

## Failure Behavior

- **On Invalid Input**: Reject with the field and reason named; no catalog change (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; return no catalog data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the named skill exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; no partially created or partially renamed skill (SEC-ERR-2)
- **Logging / Audit**: Catalog changes logged with actor, action, target and timestamp (SEC-LOG-2)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Name normalization and uniqueness comparison; retirement state transitions; axis candidate filtering
- **Integration Tests**: Uniqueness enforced at the data store under concurrent creation; retired skill excluded from the assessment write path
- **Security Tests**: Role sweep over write endpoints (SEC-AUTHZ-5, SEC-AUTHZ-6); injection payloads in catalog sort and filter parameters (SEC-INPUT-6); markup payloads in skill names rendered literally (SEC-RENDER-1)
- **Compliance Tests / Evidence**: N/A
- **Acceptance-Criteria Traceability**: AC-01 and AC-02 by REQ-SKILL-010; AC-03 by REQ-SKILL-020
- **Coverage Target**: Positive and negative coverage on uniqueness, retirement and authorization
- **Required Test Environment**: The `UT-10.1` fixture — ten skills, at least one retired

## Dependencies

- **Upstream Requirements**: REQ-FOUND-020, REQ-AUTH-060
- **Downstream Requirements**: REQ-SCORE-000, REQ-EXAM-000, REQ-CHART-000, REQ-PORT-000
- **Child Requirements**:
  - [ ] {{ISSUE_URL:REQ-SKILL-010}} — Skill catalog administration with duplicate active-name rejection
  - [ ] {{ISSUE_URL:REQ-SKILL-020}} — Retire a skill, retaining history and excluding it from new assessments
  - [ ] {{ISSUE_URL:REQ-SKILL-030}} — Axis candidate list for chart configuration
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Only Skill Catalog mutates skills (DR-3); Assessment references them by identity.
- **Prohibited Approaches**: Uniqueness enforced only in application logic; deleting a retired skill's historical scores
- **Implementation Guidance**: Model retirement as a status on the skill, not a deletion, so FR-3.4 holds naturally.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/spec-auditor.md`
- **Required Human Review**: Architecture reviewer for the retirement model
- **Open Decisions**: None blocking
