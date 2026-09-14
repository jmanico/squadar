# [REQ-SCORE-040] Stamp every score with its method, source and recorded date

## Metadata

- **ID**: REQ-SCORE-040
- **Title**: Stamp every score with its method, source and recorded date
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-SCORE-000; `REQUIREMENTS.md` FR-4.5, FR-5.3, FR-5.11; `SECURITY.md` SEC-INPUT-3

## Requirement

- **Statement**: The system MUST record, with each score, the skill, the team member, the assessment method, the assessor or exam that produced it, and the date recorded; MUST make that method visible wherever a score is shown in detail; and a self-assessed score MUST be distinguishable from an assessor-rated or exam-derived one in the score detail view.
- **Rationale**: FR-4.5 fixes the provenance fields; FR-5.3 makes the method visible in detail views; FR-5.11 singles out self-assessment as the case that must be distinguishable, because a self-assessed 9 and an exam-derived 9 are not the same claim.
- **Assumptions**: FR-5.11 is marked **(assumed)** in `REQUIREMENTS.md` and stands. This issue records and displays the method; whether a self-assessed score counts as the *current* score on a chart is `OQ-3`, out of scope and blocking REQ-SCORE-070.
- **Out of Scope**: Which actors may record by which method (REQ-SCORE-070, blocked); the exam scoring path itself (REQ-EXAM-050); the audit entry, which is a separate record (REQ-SCORE-060).
- **Design Traceability**: `DESIGN.md` — Layout and Spacing (Density: detail views are comfortable, 16–24 px internal padding), Typography (Caption for metadata), Accessibility (Not colour alone — the method is a label, never a hue).
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment — stamps method, source and date on every score (FR-4.5, FR-5.3, FR-5.11); supports exam, assessor-rating and self-assessment methods; DR-3.
- **Security Traceability**: SEC-INPUT-3, SEC-DATA-4, SEC-LOG-1, SEC-BIZ-1.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; REST API; Web Client
- **Interfaces / Operations**: Every score write path; the score detail view
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: REQ-SCORE-010 and REQ-SCORE-020 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data — the source names the assessor as well as the assessed
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Integrity, Accountability, Authenticity
- **Control Layers**: Input Validation, Business-Rule Validation, Logging and Monitoring
- **Threat References**: STRIDE — Tampering, Repudiation; CWE-915 Improperly Controlled Modification of Dynamically-Determined Object Attributes; CWE-345 Insufficient Verification of Data Authenticity
- **Abuse / Misuse Case**: A caller submitting `method: "exam"` alongside a self-assessed score so it appears exam-derived; a caller supplying the recorded date to backdate an assessment; a caller naming another assessor as the source to attribute the rating to them.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Any method, source or date field appearing in a score payload
- **Authoritative Enforcement Point**: Assessment, deriving all three from the authenticated context and the write path taken, never from the request (SEC-INPUT-3)
- **Independent Verification**: Mass-assignment tests submitting each derived field and asserting the server value prevails (SEC-INPUT-3)
- **Zero Trust Relevance**: N/A — provenance derivation, not a resource-access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: CWE-915 is cited because SEC-INPUT-3's prohibition is precisely a mass-assignment control over the derived provenance fields.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a score recorded by any supported method, when it is read in detail, then the skill, the team member, the method, the assessor or exam that produced it, and the date recorded are all present and the method is visible (FR-4.5, FR-5.3).
2. **AC-02 — Boundary or failure behavior**: Given a self-assessed score and an assessor-rated score with the same value for the same member and skill at different times, when each is shown in the score detail view, then the two are distinguishable by their recorded method (FR-5.11).
3. **AC-03 — Prohibited behavior**: Given a score payload carrying a method, source or recorded date, when it is submitted, then those client-supplied values MUST NOT be recorded — the server derives all three from the authenticated actor and the write path (SEC-INPUT-3).

## Failure Behavior

- **On Invalid Input**: Reject the write; record no score and no provenance (SEC-INPUT-1)
- **On Authentication Failure**: Refuse — without an authenticated actor there is no source to derive (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming the member or score exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; a score MUST NOT be recorded without its provenance (SEC-ERR-2)
- **Logging / Audit**: The audit entry REQ-SCORE-060 writes names the method, which is derived here (SEC-LOG-1); score values MUST NOT appear in general logs (SEC-LOG-3)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Provenance derivation per write path — assessor rating, self-assessment, exam; date stamping from the server clock; the method vocabulary
- **Integration Tests**: A score recorded through each path and read back in detail with the correct method and source; the score detail view rendering the method
- **Security Tests**: Mass-assignment tests submitting `method`, `source`, `assessorId`, `examId` and `recordedDate`, asserting the server value prevails in every case (SEC-INPUT-3); a response-shape test per role confirming the source is disclosed only where the role requires it (SEC-DATA-4)
- **Compliance Tests / Evidence**: WCAG 2.2 AA — the method is conveyed as a label, not by colour or position alone
- **Acceptance-Criteria Traceability**: AC-01 by the detail-read tests; AC-02 by the self-versus-assessor comparison test; AC-03 by the mass-assignment suite
- **Coverage Target**: Every write path × every derived field, positive and negative
- **Required Test Environment**: The `UT-10.1` fixture with scores recorded by more than one method for the same member and skill

## Dependencies

- **Upstream Requirements**: REQ-SCORE-010, REQ-SCORE-020, REQ-AUTH-050
- **Downstream Requirements**: REQ-SCORE-050, REQ-SCORE-060, REQ-SCORE-070, REQ-EXAM-050, REQ-PORT-010
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: The method vocabulary is exactly the three `REQUIREMENTS.md` names — exam (FR-5.1), assessor rating and self-assessment (FR-5.2). Do not invent a fourth.
- **Prohibited Approaches**: Accepting any provenance field from the client; deriving the date from a client-supplied timestamp; inferring the method from the payload's shape rather than from the endpoint and the authenticated actor
- **Implementation Guidance**: Make the method a property of the write path rather than a parameter of it — an endpoint that can record any method on request is the thing SEC-INPUT-3 is guarding against.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — input handling and data protection (`CLAUDE.md`)
- **Open Decisions**: `OQ-3` is recorded and out of scope here: this issue makes the method visible and distinguishable, which is all FR-5.3 and FR-5.11 require. Whether a self-assessed score counts as current is `PQ-5`, blocking REQ-SCORE-070.
- **Estimated effort**: 0.5–1 engineer-day; 250–450 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a stated set of fields with one clear prohibition, covered by a named mass-assignment suite.
