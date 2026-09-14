# [REQ-PORT-010] Team member self-export of their own skill and exam record

## Metadata

- **ID**: REQ-PORT-010
- **Title**: Team member self-export of their own skill and exam record
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Privacy
- **Source / Parent**: REQ-PORT-000; `REQUIREMENTS.md` FR-8.3, FR-1.4; `SECURITY.md` SEC-DATA-2

## Requirement

- **Statement**: A team member MUST be able to export their own complete skill and exam record in a machine-readable format, and that export MUST contain that member's own record only — no other individual's scores, no exam answer keys, and no internal system identifiers beyond those needed to interpret the record.
- **Rationale**: FR-8.3 gives each person access to the data held about them, which `REQUIREMENTS.md` frames as a privacy constraint: skill scores and exam results are personal performance data about identifiable individuals. SEC-DATA-2 bounds what the export may contain.
- **Assumptions**: FR-8.3 is marked **(assumed)** in `REQUIREMENTS.md` and stands. "Complete" is read as current scores, score history, assessment provenance and exam attempt results — everything Assessment holds about that member.
- **Out of Scope**: Bulk import (REQ-PORT-020, blocked); deletion (REQ-ROSTER-050, blocked); retention periods (SEC-DATA-6, pending `PQ-13`).
- **Design Traceability**: `DESIGN.md` — Components (Buttons: an export that is slow shows a busy state and stays disabled until it resolves), Form feedback and errors (success is confirmed in text and persists until the user moves on).
- **Architecture Traceability**: `ARCHITECTURE.md` Bulk Import / Export — produces a team member's machine-readable record export (FR-8.3), reads through Assessment, owns nothing durable; DR-3, DR-4, DR-8.
- **Security Traceability**: SEC-DATA-2, SEC-AUTHZ-3, SEC-BOUND-3, SEC-DATA-4, SEC-HTTP-5, SEC-LOG-2, SEC-ERR-1.

## Scope

- **Applies To**: Multiple
- **Components**: Bulk Import / Export; Assessment; REST API; Web Client
- **Interfaces / Operations**: Self-export request; export document generation
- **Actors**: Team Member (the only actor whose own record this is)
- **Preconditions**: REQ-SCORE-050, REQ-EXAM-050 and REQ-AUTH-050 are Verified; the caller is linked to a team member record
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`; if GDPR or CCPA apply, this is the portability path and its shape would be constrained accordingly

## Security Context

- **Security Objectives**: Privacy, Confidentiality, Authorization
- **Control Layers**: Authorization, Data Protection
- **Threat References**: STRIDE — Information Disclosure, Elevation of Privilege; OWASP Top 10:2025 Broken Access Control; CWE-639 Authorization Bypass Through User-Controlled Key; CWE-200 Exposure of Sensitive Information to an Unauthorized Actor
- **Abuse / Misuse Case**: An export request naming another member's identifier and being honoured; an export that includes exam answer keys alongside the attempt results; an export that leaks internal identifiers or another individual's data through a shared team or exam record; an export endpoint used repeatedly to extract the roster.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Any member identifier in the export request
- **Authoritative Enforcement Point**: The REST API and Assessment, scoping the export from the caller's own resolved member linkage rather than from the request (SEC-DATA-2, SEC-AUTHZ-3)
- **Independent Verification**: An export test as a Team Member asserting content is scoped to the caller (SEC-DATA-2); SEC-AUTHZ-3's test set names the export route explicitly
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — export scope is derived from the requester's identity per request, never from a parameter

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no control mapping verified against a specific catalog release
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13` (`SQ-1`); portability is one of the data-subject rights SEC-DATA-6 leaves undecided
- **Other**: N/A
- **Mapping Basis**: Regulatory scope is TO BE DECIDED rather than N/A because `SQ-1` leaves GDPR and CCPA applicability open and this endpoint is the portability surface if they apply.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a Team Member with current scores, score history and exam attempt results, when they export their own record, then the export is machine-readable and contains all of that data for them, with each score's method, source and recorded date (FR-8.3, FR-4.5).
2. **AC-02 — Boundary or failure behavior**: Given a Team Member who submits an export request naming another member's identifier, when it is processed, then the export is scoped to the caller's own record regardless, or the request is refused — in neither case is the other member's data returned (FR-1.4, SEC-AUTHZ-3).
3. **AC-03 — Prohibited behavior**: Given any export, when it is inspected, then it MUST NOT contain another individual's scores, any exam answer key, or internal system identifiers beyond those needed to interpret the record (SEC-DATA-2, SEC-BOUND-3).

## Failure Behavior

- **On Invalid Input**: Reject a malformed request; produce no document (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; produce no document (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the named member exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default — if the caller cannot be linked to a member record, no export is produced (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Produce no partial document; return an error with no internal detail (SEC-ERR-1, SEC-ERR-2)
- **Logging / Audit**: Export requests logged with actor, action, target and timestamp (SEC-LOG-2); the exported content MUST NOT be logged (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — repeated-export thresholds depend on `PQ-10`

## Test Strategy

- **Unit Tests**: Export document construction; scope derivation from the caller's member linkage; exclusion of answer keys and of other members' data
- **Integration Tests**: An export round trip against the fixture asserting completeness — every current score, history entry and exam result for that member and nothing else
- **Security Tests**: An export test as a Team Member asserting content is scoped to the caller (SEC-DATA-2); an export request naming another member's identifier (SEC-AUTHZ-3); a search of the export for the fixture's known answer-key values asserting absence (SEC-BOUND-3); request-rate and request-size limits on the export endpoint (SEC-HTTP-5)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`; if GDPR or CCPA apply, evidence that the export satisfies portability would be required
- **Acceptance-Criteria Traceability**: AC-01 by the completeness test; AC-02 by the other-identifier test; AC-03 by the content-exclusion searches
- **Coverage Target**: Positive and negative coverage on scope derivation and on every exclusion
- **Required Test Environment**: The `UT-10.1` fixture with a member holding scores, history and exam attempts, and at least one other member whose data must not appear

## Dependencies

- **Upstream Requirements**: REQ-SCORE-040, REQ-SCORE-050, REQ-EXAM-050, REQ-AUTH-050, REQ-AUTH-060
- **Downstream Requirements**: None
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Bulk Import / Export owns nothing durable; it reads through Assessment (DR-4). The export is a read of data the caller is already entitled to, assembled rather than newly authorized.
- **Prohibited Approaches**: Taking the export's subject from a request parameter; including the full exam definition with its key alongside an attempt result; exporting internal identifiers that are not needed to interpret the record (SEC-DATA-2)
- **Implementation Guidance**: Test by searching the produced document for the fixture's literal answer-key values and for another member's known name — an exclusion asserted only by inspecting the intended shape will not catch a nested inclusion.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — data protection (`CLAUDE.md`); privacy reviewer once `PQ-13` is answered
- **Open Decisions**: `PQ-13` is recorded — regulatory applicability would constrain the export's shape and the rights it must serve. It does not block FR-8.3 as stated.
- **Estimated effort**: 1–1.5 engineer-days; 350–600 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — an endpoint whose whole purpose is to emit personal data, where the exclusions are what matter and a nested inclusion is easy to miss.
