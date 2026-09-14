# [REQ-SKILL-010] Skill catalog administration with duplicate active-name rejection

## Metadata

- **ID**: REQ-SKILL-010
- **Title**: Skill catalog administration with duplicate active-name rejection
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-SKILL-000; `REQUIREMENTS.md` FR-3.1, FR-3.2, FR-3.3

## Requirement

- **Statement**: The system MUST maintain a single system-wide catalog of named skills, an Administrator MUST be able to add and rename skills in it, and the system MUST reject a skill whose name duplicates an existing active skill.
- **Rationale**: FR-3.1 makes one catalog the basis of comparability across members; FR-3.3's uniqueness rule is what stops a member's history splitting across two records that mean the same thing.
- **Assumptions**: FR-3.1 is marked **(assumed)** in `REQUIREMENTS.md` — one system-wide catalog rather than per-team catalogs — and stands.
- **Out of Scope**: Retirement (REQ-SKILL-020); the axis candidate list (REQ-SKILL-030); skill grouping or categorization, which `ARCHITECTURE.md` leaves `UNKNOWN`.
- **Design Traceability**: `DESIGN.md` — Components (Inputs: persistent visible label, helper text in Small/`text-muted`, required fields marked in the label), Form feedback and errors (an error names what is wrong and what to do).
- **Architecture Traceability**: `ARCHITECTURE.md` Skill Catalog — owns skills; the single system-wide catalog; rejection of duplicate active names; DR-3, DR-4.
- **Security Traceability**: SEC-AUTHZ-1, SEC-AUTHZ-5, SEC-AUTHZ-6, SEC-INPUT-1, SEC-INPUT-6, SEC-RENDER-1, SEC-ERR-2, SEC-LOG-2.

## Scope

- **Applies To**: Multiple
- **Components**: Skill Catalog; Relational Data Store; REST API; Web Client
- **Interfaces / Operations**: Skill add; skill rename; active catalog list
- **Actors**: Administrator (write); all roles (read)
- **Preconditions**: REQ-FOUND-020 and REQ-AUTH-060 are Verified
- **Data Classification**: Internal
- **Personal or Regulated Data**: None
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Integrity, Authorization
- **Control Layers**: Authorization, Input Validation, Business-Rule Validation, Output Encoding
- **Threat References**: STRIDE — Tampering; OWASP Top 10:2025 Broken Access Control; CWE-20 Improper Input Validation; CWE-79 Improper Neutralization of Input During Web Page Generation
- **Abuse / Misuse Case**: A non-Administrator adding or renaming a skill; a duplicate slipping past a case-sensitive or whitespace-sensitive comparison and splitting a member's history; a skill name carrying markup into a chart axis label or table header; an injection payload in a catalog sort or filter parameter.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Skill names, skill identifiers, and catalog sort and filter parameters
- **Authoritative Enforcement Point**: Skill Catalog behind the REST API, with uniqueness also enforced in the Relational Data Store
- **Independent Verification**: A concurrent-creation test at the data store level, which application-level checking alone would pass and then fail in production
- **Zero Trust Relevance**: N/A — catalog reads are permitted to every authenticated role

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: N/A
- **Mapping Basis**: No standard mapping is verified for catalog administration; the governing rules are FR-3.1–FR-3.3 and SEC-INPUT-1.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an Administrator, when they add a skill whose name matches no active skill, then the skill is created and appears in the active catalog (FR-3.1, FR-3.2).
2. **AC-02 — Boundary or failure behavior**: Given an active skill named "TypeScript", when a second skill with that name is submitted — including with differing case or surrounding whitespace, under the comparison rule the implementation defines and documents — then it is rejected with a stated reason and no second record is created (FR-3.3).
3. **AC-03 — Prohibited behavior**: Given any non-Administrator, when they attempt to add or rename a skill, then it MUST NOT take effect (FR-1.3, SEC-AUTHZ-5, SEC-AUTHZ-6); and given a skill name containing HTML markup, it MUST NOT be rendered as markup anywhere it is displayed (SEC-RENDER-1).

## Failure Behavior

- **On Invalid Input**: Reject with the field and a product-term reason; no catalog change (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; return no catalog data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the named skill exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; no partially created or partially renamed skill (SEC-ERR-2)
- **Logging / Audit**: Skill add and rename logged with actor, action, target and timestamp (SEC-LOG-2)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Name normalization and the uniqueness comparison, including case and whitespace variants; rename validation against the same rule
- **Integration Tests**: Concurrent creation of two skills with the same name asserting exactly one succeeds, enforced at the data store
- **Security Tests**: The role sweep over add and rename (SEC-AUTHZ-5, SEC-AUTHZ-6); injection payloads in catalog sort and filter parameters (SEC-INPUT-6); markup payloads in a skill name asserted to render literally (SEC-RENDER-1)
- **Compliance Tests / Evidence**: N/A
- **Acceptance-Criteria Traceability**: AC-01 by the creation test; AC-02 by the uniqueness suite and the concurrency test; AC-03 by the role sweep and the rendering test
- **Coverage Target**: Positive and negative coverage on uniqueness and on both write operations
- **Required Test Environment**: The `UT-10.1` fixture — ten skills

## Dependencies

- **Upstream Requirements**: REQ-FOUND-020, REQ-AUTH-060, REQ-UIKIT-050
- **Downstream Requirements**: REQ-SKILL-020, REQ-SKILL-030, REQ-SCORE-010, REQ-EXAM-010, REQ-PORT-020
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Uniqueness applies to *active* skills only — a retired skill's name does not block a new one, because FR-3.4 keeps retired skills for history rather than for use. Only Skill Catalog mutates skills (DR-3).
- **Prohibited Approaches**: Uniqueness enforced only in application logic, which a concurrent create defeats; a rename that silently merges two skills' histories
- **Implementation Guidance**: The comparison rule for "duplicates" — case folding and whitespace handling — is not stated in `REQUIREMENTS.md`. Choose one, document it in the issue's implementation and in `REQUIREMENTS.md` if it changes observable behavior, and test both the matching and non-matching sides.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/spec-auditor.md` before the pull request
- **Required Human Review**: Architecture reviewer for the uniqueness constraint's placement
- **Open Decisions**: None blocking. The exact name-comparison rule is a local implementation decision to be recorded, not a product question.
- **Estimated effort**: 0.5–1 engineer-day; 250–450 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — routine catalog CRUD with one uniqueness constraint that must also exist in the data store, which the concurrency test verifies.
