# [REQ-PORT-020] Bulk delimited import of team members and skills with per-row rejection reasons

> **BLOCKED — do not implement.** Blocked on `PQ-15`. See **Open Decisions**.

## Metadata

- **ID**: REQ-PORT-020
- **Title**: Bulk delimited import of team members and skills with per-row rejection reasons
- **Version**: 0.1.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Medium
- **Requirement Type**: Functional
- **Source / Parent**: REQ-PORT-000; `REQUIREMENTS.md` FR-8.2, FR-8.1; `SECURITY.md` SEC-INPUT-4, SEC-INPUT-5

## Requirement

- **Statement**: An Administrator MUST be able to import team members and skills in bulk from a delimited file; the system MUST report, per row, any row it rejected and why; each row MUST be validated through the same server-side rules as interactive entry; and no row MUST bypass role, uniqueness or range validation.
- **Rationale**: FR-8.2 states the import and its per-row report. SEC-INPUT-4 makes the rules identical to the interactive path, which is what stops import becoming a second, weaker door into the same data.
- **Assumptions**: FR-8.2 is marked **(assumed)** in `REQUIREMENTS.md` and stands. What is unresolved is the file format, the size limits and whether large imports run synchronously or as background work.
- **Out of Scope**: Interactive entry (REQ-PORT-030); self-export (REQ-PORT-010); score import, which `REQUIREMENTS.md` does not provide for — FR-8.2 names team members and skills only.
- **Design Traceability**: `DESIGN.md` — Components (Buttons: a slow action shows a busy state and stays disabled until it resolves), Form feedback and errors (on submit failure a summary lists every error with links to the fields — the per-row report follows the same pattern), Layout and Spacing (the report is a compact table).
- **Architecture Traceability**: `ARCHITECTURE.md` Bulk Import / Export — parses delimited bulk import and reports per-row rejections with reasons; validates shape and then submits each row through the owning component; file format specifics, size limits and whether large imports run synchronously or as background work are `TO BE DECIDED`; DR-1, DR-3, DR-4.
- **Security Traceability**: SEC-INPUT-4, SEC-INPUT-5, SEC-EXT-4, SEC-AUTHZ-4, SEC-AUTHZ-5, SEC-AUTHZ-6, SEC-BIZ-3, SEC-ERR-2, SEC-HTTP-5, SEC-LOG-2.

## Scope

- **Applies To**: Multiple
- **Components**: Bulk Import / Export; Roster; Skill Catalog; REST API; Web Client
- **Interfaces / Operations**: File upload; row parsing and validation; the per-row accept/reject report
- **Actors**: Administrator
- **Preconditions**: REQ-ROSTER-020, REQ-SKILL-010 and REQ-FOUND-020 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data — imported rows name individuals
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Integrity, Authorization, Availability, Confidentiality
- **Control Layers**: Input Validation, Authorization, Business-Rule Validation, Availability
- **Threat References**: STRIDE — Tampering, Elevation of Privilege, Denial of Service; OWASP Top 10:2025 Injection; CWE-1236 Improper Neutralization of Formula Elements in a CSV File; CWE-22 Improper Limitation of a Pathname to a Restricted Directory; CWE-409 Improper Handling of Highly Compressed Data; CWE-918 Server-Side Request Forgery
- **Abuse / Misuse Case**: A row bypassing the uniqueness or role rules the interactive path enforces; a formula-bearing cell evaluated at parse time or on later export into a spreadsheet; an uploaded file stored under a caller-controlled path or name; an oversized or highly compressed file exhausting the parser; a URL in a cell that the server dereferences; an import half-applied and left that way.
- **Trust Boundary**: Clients → REST API; the uploaded file entering the API
- **Untrusted Inputs or Assertions**: The file, its declared type and size, its filename, and every cell value
- **Authoritative Enforcement Point**: The owning component per row — Roster for members, Skill Catalog for skills — reached through the same rules as interactive entry (SEC-INPUT-4)
- **Independent Verification**: An import fixture mixing valid and invalid rows, asserting identical rejection reasons to the interactive path and no partially applied write (SEC-INPUT-4)
- **Zero Trust Relevance**: N/A — input validation and authorization, not a distinct resource-access model

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: CWE-1236 is cited because SEC-INPUT-5 names embedded formulas explicitly, and it is the failure mode a delimited-file importer most often overlooks.

## Acceptance Criteria

The file format, the size and type limits, and whether large imports run synchronously or as
background work are all `TO BE DECIDED`. Those decisions determine the request and response shapes,
what a partial failure looks like, and whether the per-row report is returned inline or polled —
which is most of what the expected and failure criteria would say. The criteria that hold under any
answer are stated.

1. **AC-01 — Expected behavior**: BLOCKED on `PQ-15`.
2. **AC-02 — Boundary or failure behavior**: BLOCKED on `PQ-15` for the delivery shape. Independent of it: given a file mixing valid and invalid rows, when it is imported, then each rejected row is reported with the same reason the interactive path would give for the same value, and no partially applied write remains (FR-8.2, SEC-INPUT-4, SEC-ERR-2).
3. **AC-03 — Prohibited behavior**: Given any imported row, when it is processed, then it MUST NOT bypass role, uniqueness or range validation (SEC-INPUT-4). Given any uploaded file, it MUST NOT be parsed in a way that evaluates embedded formulas, macros or references to external resources, and MUST NOT be stored under a caller-controlled filesystem path or name (SEC-INPUT-5). Given a URL in any cell, the server MUST NOT dereference it (SEC-EXT-4). All hold regardless of how `PQ-15` is answered.

## Failure Behavior

- **On Invalid Input**: Reject the row with the same reason the interactive path gives; reject the whole file before parsing if its declared size or type is not permitted (SEC-INPUT-4, SEC-INPUT-5)
- **On Authentication Failure**: Refuse (SEC-AUTHN-1)
- **On Authorization Failure**: Deny — import is Administrator-only (SEC-AUTHZ-6); an Assessor MUST NOT reach a write for an out-of-team member through this path (SEC-AUTHZ-4); a Viewer has no import path (SEC-AUTHZ-5)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A — the server MUST NOT fetch a URL derived from imported data (SEC-EXT-4)
- **On System Error**: Roll back the whole import run rather than leaving it half-applied (SEC-ERR-2)
- **Logging / Audit**: Import runs logged with actor, action, target and timestamp (SEC-LOG-2); cell contents MUST NOT be logged (SEC-LOG-3). Rows creating members or skills produce the same audit trail the interactive path does
- **Alerting**: TO BE DECIDED — depends on `PQ-10`

## Test Strategy

- **Unit Tests**: Row parsing and shape validation; the per-row reason mapping asserted equal to the interactive path's; the size and type gate
- **Integration Tests**: BLOCKED on `PQ-15` for the synchronous-versus-background path; the mixed-row fixture is testable once the format is fixed
- **Security Tests**: An import fixture mixing valid and invalid rows asserting identical reasons to the interactive path and no partial write (SEC-INPUT-4); oversized files, mismatched declared types, formula-bearing cells and path-traversal filenames (SEC-INPUT-5); an Assessor importing rows naming out-of-team members (SEC-AUTHZ-4); a Viewer attempting import (SEC-AUTHZ-5); rows naming a deactivated member or retired skill (SEC-BIZ-3); internal and metadata-endpoint URLs in any dereferenceable field (SEC-EXT-4); request-rate and request-size limits (SEC-HTTP-5)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-02's parity clause and AC-03 by the SEC-INPUT-4, SEC-INPUT-5 and SEC-EXT-4 suites; AC-01 deferred with the criterion
- **Coverage Target**: Every interactive validation rule asserted to produce the same rejection on the import path
- **Required Test Environment**: Import fixtures containing valid, invalid and hostile rows; the `UT-10.1` fixture as the pre-existing state against which uniqueness is tested

## Dependencies

- **Upstream Requirements**: REQ-FOUND-020, REQ-ROSTER-020, REQ-SKILL-010, REQ-AUTH-060, REQ-UIKIT-050
- **Downstream Requirements**: None
- **External Dependencies**: A delimited-file parsing library, if added — justified against DEP-1…DEP-8, with DEP-6 weighing the transitive tree and DEP-8 preferring the narrowest scope
- **Dependency Assumptions**: Any parser chosen does not evaluate embedded formulas or fetch external references by default, or is configured not to; the tests assert this rather than trusting it (SEC-INPUT-5).
- **Failure Impact**: A parser that dereferences external entities or evaluates formulas would turn this endpoint into a server-side request forgery and injection vector at once.

## Implementation Notes

- **Constraints**: Import writes through Roster and Skill Catalog and owns nothing durable (DR-3, DR-4). It validates shape, then submits each row through the owning component — it does not reimplement the rules.
- **Prohibited Approaches**: A separate import validation path that can drift from the interactive one (SEC-INPUT-4); trusting the declared content type; storing the upload under its supplied filename; a partially applied run left in place
- **Implementation Guidance**: None on format or execution model while blocked. The parity requirement is the design constraint that matters: reuse the `shared/` schemas from REQ-FOUND-020 and call the same component interfaces the interactive path calls, so "the same rules" is structural rather than a matter of discipline.
- **AI Development Guidance**: `CLAUDE.md`; do not implement while BLOCKED
- **Required Human Review**: Architecture owner to answer `PQ-15`; human security review before merge — input handling at a trust boundary (`CLAUDE.md`)
- **Open Decisions**: **`PQ-15` (blocking)** — `ARCHITECTURE.md` Bulk Import / Export: file format specifics, size limits, and whether large imports run synchronously or as background work are `TO BE DECIDED`; SEC-INPUT-5 leaves the size and type limits `TO BE DECIDED` as well. `PQ-10` (`SQ-9`) is recorded alongside, since SEC-HTTP-5's import limits depend on it.
- **Estimated effort**: Not estimated while blocked — a background execution model is materially more work than a synchronous one.
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — a file-parsing endpoint at a trust boundary with four distinct injection and resource failure classes, plus an all-or-nothing transactional requirement; to be confirmed once `PQ-15` fixes the execution model.
