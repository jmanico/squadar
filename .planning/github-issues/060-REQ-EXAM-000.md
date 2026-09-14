# [REQ-EXAM-000] Exams, assignment, attempts and scoring

## Metadata

- **ID**: REQ-EXAM-000
- **Title**: Exams, assignment, attempts and scoring
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Functional
- **Source / Parent**: REQ-EPIC-001; `REQUIREMENTS.md` FR-5.1, FR-5.4–FR-5.10, NFR-9.2, NFR-9.7; `ARCHITECTURE.md` Assessment, Outbound Notification, Protected Asset Store

## Requirement

- **Statement**: The system MUST let an Administrator define an exam for a single skill, let an Assessor or Administrator assign it, let only an assigned Team Member attempt it, score the submission server-side into a 1–10 band and record the result against the exam's skill — without an answer key ever reaching a Team Member or Viewer; delivery is the sum of its children.
- **Rationale**: FR-5.1 makes the exam the primary assessment method, and NFR-9.7 makes answer-key confidentiality an absolute. FR-5.7 fixes the conversion so a score is reproducible from the answers alone.
- **Assumptions**: The band conversion in FR-5.7 is marked **(assumed)** and stands: ten equal bands, 1–10% yields 1, 91–100% yields 10, and 0% yields 1.
- **Out of Scope**: Per-question weights, pass thresholds and manual review (`OQ-2`); attempt timing, resumption and retake policy (`PQ-4`, blocking REQ-EXAM-040); exam media storage (`PQ-16`, blocking REQ-EXAM-070).
- **Design Traceability**: `DESIGN.md` — Layout and Spacing (long-form text caps at 72 characters, which the exam-question surface uses); Components (Buttons that start a slow action show a busy state and stay disabled until it resolves); Accessibility (taking and submitting an exam by keyboard alone).
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment; Outbound Notification; Protected Asset Store; Primary Flow 3; DR-3, DR-6, DR-8, DR-9.
- **Security Traceability**: SEC-BOUND-3, SEC-BOUND-4, SEC-RENDER-4, SEC-AUTHZ-6, SEC-AUTHZ-8, SEC-BIZ-1, SEC-INPUT-3, SEC-INPUT-5, SEC-AUTHN-8, SEC-EXT-1, SEC-EXT-3, SEC-LOG-3, SEC-ERR-2, SEC-HTTP-5.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; REST API; Web Client; Outbound Notification; Protected Asset Store
- **Interfaces / Operations**: Exam definition; exam assignment and invitation; exam delivery to an assignee; submission and automatic scoring; result display
- **Actors**: Administrator, Assessor, Team Member, Viewer, mail provider
- **Preconditions**: The exam's skill is active (FR-3.4) and the assigned member is active (FR-2.3)
- **Data Classification**: Restricted — answer keys and attempt results
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Multiple
- **Control Layers**: Authorization, Business-Rule Validation, Input Validation, Data Protection, Logging and Monitoring
- **Threat References**: STRIDE — Information Disclosure (answer keys), Tampering (forged score), Elevation of Privilege (attempting an unassigned exam); OWASP Top 10:2025 Broken Access Control
- **Abuse / Misuse Case**: A Team Member reading the answer key from the exam payload, a cached response, an error path or a source map; a submission carrying a forged score or percentage; attempting an exam that was never assigned; resubmitting a completed attempt; an invitation link reused or used by a different account.
- **Trust Boundary**: Clients → REST API; API → Protected Asset Store; API → mail provider
- **Untrusted Inputs or Assertions**: Submitted answers, exam and attempt identifiers, any score or percentage field in a submission, uploaded exam media
- **Authoritative Enforcement Point**: Assessment — answer keys are filtered inside the owning component before the response is assembled (SEC-BOUND-3, DR-8)
- **Independent Verification**: The recorded score derives from the stored answer key and the submitted answers only; a client-submitted score is ignored (SEC-BIZ-1)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — an attempt is authorized per request against the assignment record, not against session state

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A — exam scoring is deterministic, with no AI-enabled component
- **NIST SP 800-53 Rev. 5**: N/A — no mapping verified against the catalog release
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: AISVS is explicitly N/A rather than unassessed: `REQUIREMENTS.md` specifies arithmetic scoring against a stored key.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a Team Member with an assigned exam of 10 questions, when they submit 7 correct answers, then the percentage is 70%, the recorded score is 7, it is stamped with the exam method and source, it is shown to the submitting member, and it is available for display immediately (FR-5.7, FR-5.8, FR-5.9).
2. **AC-02 — Boundary or failure behavior**: Given a Team Member, when they request or submit an exam that has not been assigned to them, then the request is denied without confirming whether that exam exists (FR-5.6, SEC-AUTHZ-8, SEC-AUTHZ-7).
3. **AC-03 — Prohibited behavior**: Given any exam payload, cached response, error response or client state reaching a Team Member or Viewer, when it is inspected, then it MUST NOT contain answer-key data in any field (NFR-9.7, SEC-BOUND-3, SEC-RENDER-4).

## Failure Behavior

- **On Invalid Input**: Reject the submission; record no attempt result and no score (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; return no exam content (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without disclosing the exam's existence or content (SEC-AUTHZ-7, SEC-AUTHZ-8)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: A mail-provider failure MUST NOT block the assignment itself; the invitation is retried or reported, and the assignment stands (DR-6)
- **On System Error**: Roll back; never an exam scored without its audit entry, nor an attempt marked complete without its score (SEC-ERR-2)
- **Logging / Audit**: The resulting score's create produces an audit entry (SEC-LOG-1); answer keys and score values MUST NOT appear in logs (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — submission abuse thresholds depend on `PQ-10`

## Test Strategy

- **Unit Tests**: Percentage computation and band conversion at every boundary (0%, 1%, 10%, 11%, 90%, 91%, 100%); assignment predicate; answer-key exclusion from the delivery shape
- **Integration Tests**: Primary Flow 3 end to end; the new score picked up by a subsequent chart read (FR-5.10); NFR-9.2 timing under the fixture
- **Security Tests**: Submission with a forged score field (SEC-BIZ-1); unassigned and resubmitted attempts (SEC-AUTHZ-8); network-payload and client-state inspection for key leakage (SEC-RENDER-4); invitation-link reuse, expiry and wrong-account tests (SEC-AUTHN-8); message-template review against a permitted-field list (SEC-EXT-3)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by REQ-EXAM-050; AC-02 by REQ-EXAM-040 (blocked); AC-03 by REQ-EXAM-030
- **Coverage Target**: Positive and negative coverage on the band boundaries, the assignment check and every answer-key exclusion path
- **Required Test Environment**: The `UT-10.1` fixture plus at least one exam per skill with a known key; a mail-provider simulator

## Dependencies

- **Upstream Requirements**: REQ-SCORE-010, REQ-SCORE-020, REQ-SCORE-040, REQ-SCORE-050, REQ-SCORE-060, REQ-SKILL-010, REQ-ROSTER-010, REQ-AUTH-060
- **Downstream Requirements**: REQ-CHART-010, REQ-PORT-010
- **Child Requirements**:
  - [ ] {{ISSUE_URL:REQ-EXAM-010}} — Define an exam for a single skill with its questions and answer key
  - [ ] {{ISSUE_URL:REQ-EXAM-020}} — Assign an exam and send its invitation through the notification adapter
  - [ ] {{ISSUE_URL:REQ-EXAM-030}} — Deliver an exam to an assignee with no answer-key data in the payload
  - [ ] {{ISSUE_URL:REQ-EXAM-040}} — Authorize an exam attempt against its assignment
  - [ ] {{ISSUE_URL:REQ-EXAM-050}} — Score a submission server-side and convert the percentage to a 1–10 band
  - [ ] {{ISSUE_URL:REQ-EXAM-060}} — Use the updated score everywhere after reassessment
  - [ ] {{ISSUE_URL:REQ-EXAM-070}} — Serve exam media from the protected asset store under a live authorization decision
- **External Dependencies**: Mail provider (TO BE DECIDED); asset store (TO BE DECIDED)
- **Dependency Assumptions**: Both are reached only through an adapter, and no vendor type, error or payload shape crosses out of it (DR-6, SEC-EXT-1). Neither is trusted to have delivered or stored correctly without a validated response (SEC-EXT-2).
- **Failure Impact**: An unavailable mail provider delays invitations but does not prevent an already-notified member from attempting. An unavailable asset store affects media-bearing exams only.

## Implementation Notes

- **Constraints**: Scoring is server-side and arithmetic (SEC-BIZ-1); the conversion is exactly FR-5.7's ten equal bands.
- **Prohibited Approaches**: Filtering answer keys in a serializer, view layer or client (SEC-BOUND-3, DR-8); accepting a client-supplied score or percentage (SEC-BIZ-1); embedding the key in a source map or debug field
- **Implementation Guidance**: Keep the answer key in a separate read path that no exam-delivery query touches, so the exclusion is structural rather than a filter that can be forgotten.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` on every child here
- **Required Human Review**: Human security review — answer-key confidentiality and attempt authorization
- **Open Decisions**: `PQ-4` (attempt validity, retake, timing) blocks REQ-EXAM-040; `PQ-16` (asset store) blocks REQ-EXAM-070; `OQ-2` (weights, thresholds, manual review) is recorded and does not block FR-5.7 as stated.
