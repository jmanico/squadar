# [REQ-PORT-000] Data entry, import, export and deletion

## Metadata

- **ID**: REQ-PORT-000
- **Title**: Data entry, import, export and deletion
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Medium
- **Requirement Type**: Functional
- **Source / Parent**: REQ-EPIC-001; `REQUIREMENTS.md` FR-8.1–FR-8.3; `ARCHITECTURE.md` Bulk Import / Export

## Requirement

- **Statement**: The system MUST let an Administrator create team members and skills through the user interface and in bulk from a delimited file with per-row rejection reasons, and MUST let a team member export their own complete skill and exam record in a machine-readable format; delivery is the sum of its children.
- **Rationale**: FR-8.1–FR-8.3 are the data-in and data-out edges. `ARCHITECTURE.md` requires imported rows to pass through the owning component so they meet exactly the same rules as interactive entry (SEC-INPUT-4).
- **Assumptions**: FR-8.1, FR-8.2 and FR-8.3 are all marked **(assumed)** in `REQUIREMENTS.md` and stand.
- **Out of Scope**: Deletion of a member's personal data (FR-8.4), which REQ-ROSTER-050 owns under Roster.
- **Design Traceability**: `DESIGN.md` — Components (Inputs with persistent visible labels; Buttons that show a busy state for a slow action); Form feedback and errors (on submit failure, focus moves to the first invalid field and a summary lists every error with links to the fields — the import report uses the same pattern).
- **Architecture Traceability**: `ARCHITECTURE.md` Bulk Import / Export; DR-1, DR-3, DR-4.
- **Security Traceability**: SEC-INPUT-4, SEC-INPUT-5, SEC-INPUT-6, SEC-EXT-4, SEC-DATA-2, SEC-DATA-4, SEC-AUTHZ-3, SEC-AUTHZ-4, SEC-AUTHZ-5, SEC-AUTHZ-6, SEC-ERR-2, SEC-HTTP-5, SEC-LOG-2.

## Scope

- **Applies To**: Multiple
- **Components**: Bulk Import / Export; Roster; Skill Catalog; Assessment; REST API; Web Client
- **Interfaces / Operations**: Interactive member and skill creation; delimited bulk import with a per-row report; self-export
- **Actors**: Administrator, Team Member
- **Preconditions**: The caller is authenticated and their role is resolved
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`; portability is one of the data-subject rights `SEC-DATA-6` leaves undecided

## Security Context

- **Security Objectives**: Multiple
- **Control Layers**: Authorization, Input Validation, Business-Rule Validation, Data Protection
- **Threat References**: STRIDE — Tampering, Information Disclosure; OWASP Top 10:2025 Broken Access Control
- **Abuse / Misuse Case**: An import row bypassing role, uniqueness or range validation; a formula-bearing or oversized file; a file stored under a caller-controlled path; a server-side fetch of a URL taken from an imported cell; an export returning another individual's scores or an answer key.
- **Trust Boundary**: Clients → REST API; uploaded files entering the API
- **Untrusted Inputs or Assertions**: Every uploaded file, its declared type and size, every cell value, and every identifier in an export request
- **Authoritative Enforcement Point**: The owning component for each row — Roster for members, Skill Catalog for skills — reached through the same server-side rules as interactive entry (SEC-INPUT-4)
- **Independent Verification**: An export is scoped from the caller's own resolved member linkage, not from an identifier in the request (SEC-DATA-2, SEC-AUTHZ-3)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — export scope is derived from the requester's identity per request

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no mapping verified against the catalog release
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: Regulatory scope is TO BE DECIDED rather than N/A because `SQ-1` leaves GDPR/CCPA applicability open, and portability would bear directly on this workstream if they apply.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a Team Member, when they export their own record, then the export contains that member's complete skill and exam record in a machine-readable format and nothing belonging to another individual (FR-8.3, SEC-DATA-2).
2. **AC-02 — Boundary or failure behavior**: Given an import file mixing valid and invalid rows, when it is imported, then each rejected row is reported with the same reason the interactive path would give, and no partially applied write remains (FR-8.2, SEC-INPUT-4, SEC-ERR-2).
3. **AC-03 — Prohibited behavior**: Given an export request naming another member's identifier, when a Team Member submits it, then the request MUST NOT return that member's record (FR-1.4, SEC-AUTHZ-3).

## Failure Behavior

- **On Invalid Input**: Reject the row or the request with the reason named; apply no partial write (SEC-INPUT-4, SEC-ERR-2)
- **On Authentication Failure**: Refuse; return no record data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the named member exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A — the server MUST NOT fetch a URL derived from imported data (SEC-EXT-4)
- **On System Error**: Roll back the whole import run rather than leaving it half-applied (SEC-ERR-2)
- **Logging / Audit**: Bulk import runs logged with actor, action, target and timestamp (SEC-LOG-2); cell contents and score values MUST NOT be logged (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — import size and rate thresholds depend on `PQ-10`

## Test Strategy

- **Unit Tests**: Row parsing and shape validation; export document construction; per-row reason mapping
- **Integration Tests**: Import fixture mixing valid and invalid rows asserting identical reasons to the interactive path; export round trip against the fixture
- **Security Tests**: Oversized files, mismatched declared types, formula-bearing cells, path-traversal file names (SEC-INPUT-5); internal and metadata-endpoint URLs in dereferenceable fields (SEC-EXT-4); an Assessor importing rows naming out-of-team members (SEC-AUTHZ-4); a Viewer attempting import (SEC-AUTHZ-5); export as a Team Member asserting caller scope (SEC-DATA-2)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 and AC-03 by REQ-PORT-010; AC-02 by REQ-PORT-020 (blocked)
- **Coverage Target**: Positive and negative coverage on every row-validation rule and on export scoping
- **Required Test Environment**: The `UT-10.1` fixture plus import fixtures containing valid, invalid and hostile rows

## Dependencies

- **Upstream Requirements**: REQ-ROSTER-020, REQ-SKILL-010, REQ-SCORE-050, REQ-EXAM-050, REQ-AUTH-060, REQ-UIKIT-050
- **Downstream Requirements**: None
- **Child Requirements**:
  - [ ] {{ISSUE_URL:REQ-PORT-010}} — Team member self-export of their own skill and exam record
  - [ ] {{ISSUE_URL:REQ-PORT-020}} — Bulk delimited import of team members and skills with per-row rejection reasons
  - [ ] {{ISSUE_URL:REQ-PORT-030}} — Administrator interface for creating team members and skills
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Import writes through Roster and Skill Catalog; it owns nothing durable itself (DR-3, DR-4).
- **Prohibited Approaches**: A separate import validation path that diverges from interactive rules (SEC-INPUT-4); evaluating embedded formulas, macros or external references while parsing (SEC-INPUT-5); storing an uploaded file under a caller-controlled name or path
- **Implementation Guidance**: Reuse the `shared/` schemas from REQ-FOUND-020 for row validation so the "same rules" requirement is structural.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` for the import child
- **Required Human Review**: Security review for import (input handling) and export (data protection)
- **Open Decisions**: `PQ-15` — file format, size limits and synchronous vs. background execution; blocks REQ-PORT-020 only.
