# [REQ-EXAM-040] Authorize an exam attempt against its assignment

> **BLOCKED — do not implement.** Blocked on `PQ-4`. See **Open Decisions**.

## Metadata

- **ID**: REQ-EXAM-040
- **Title**: Authorize an exam attempt against its assignment
- **Version**: 0.1.0
- **Status**: Draft
- **Owner**: Squadar product and engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Security
- **Source / Parent**: REQ-EXAM-000; `REQUIREMENTS.md` FR-5.6; `SECURITY.md` SEC-AUTHZ-8, `SQ-11`

## Requirement

- **Statement**: A Team Member MUST be able to attempt only an exam assigned to them, and the API MUST reject a submission for an unassigned, withdrawn or already-completed attempt.
- **Rationale**: FR-5.6 states the rule and SEC-AUTHZ-8 restates it at the API. What SEC-AUTHZ-8 records as `UNKNOWN`, and what this issue is blocked on, is what makes an attempt valid in the first place — whether attempts are timed, resumable, or retakeable.
- **Assumptions**: None — the attempt policy is recorded as unresolved rather than assumed.
- **Out of Scope**: Answer-key confidentiality on the delivery payload (REQ-EXAM-030); the scoring arithmetic (REQ-EXAM-050).
- **Design Traceability**: `DESIGN.md` — Components (Buttons: exam submission shows a busy state and stays disabled until it resolves, rather than being clickable twice), Accessibility (taking and submitting an exam is fully keyboard-operable), Form feedback and errors.
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment — owns exam attempts and the rule that only an assigned member may attempt an exam; exam attempt timing, resumption and retake policy is `UNKNOWN`; Primary Flow 3; DR-3.
- **Security Traceability**: SEC-AUTHZ-8, SEC-AUTHZ-1, SEC-AUTHZ-7, SEC-BOUND-1, SEC-BIZ-3, SEC-HTTP-5, SEC-ERR-2, SEC-LOG-2.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; REST API; Web Client
- **Interfaces / Operations**: Attempt start; attempt submission; attempt state
- **Actors**: Team Member (attempter); Administrator and Assessor (assigners); Viewer (no attempt path)
- **Preconditions**: REQ-EXAM-020 and REQ-EXAM-030 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data — an attempt is a record about an identified individual
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Authorization, Integrity, Accountability
- **Control Layers**: Authorization, Business-Rule Validation, Availability
- **Threat References**: STRIDE — Elevation of Privilege, Tampering; OWASP Top 10:2025 Broken Access Control; CWE-639 Authorization Bypass Through User-Controlled Key; CWE-837 Improper Enforcement of a Single, Unique Action
- **Abuse / Misuse Case**: Attempting an exam never assigned; submitting against another member's attempt; resubmitting a completed attempt to replace a poor score; repeatedly starting attempts to enumerate question content across sessions — which is exactly the case the missing retake policy leaves undefined.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Exam and attempt identifiers, submitted answers, and any attempt-state value in the request
- **Authoritative Enforcement Point**: Assessment, checking the assignment record (SEC-AUTHZ-8)
- **Independent Verification**: A test submitting an unassigned exam identifier and resubmitting a completed attempt (SEC-AUTHZ-8)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — the attempt is authorized per request against the assignment record, not against session state

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: CWE-837 is cited because "already-completed attempt" in SEC-AUTHZ-8 is a single-unique-action enforcement problem, and its boundaries depend on the unresolved retake policy.

## Acceptance Criteria

SEC-AUTHZ-8 says in terms that its retake policy is `UNKNOWN`, and `SECURITY.md` `SQ-11` states that
without a stated policy the rule "cannot fully specify what a valid attempt is". A criterion for
resumption, timeout or retake would therefore be invented product behavior. The two clauses that do
not depend on the policy are stated.

1. **AC-01 — Expected behavior**: BLOCKED on `PQ-4`.
2. **AC-02 — Boundary or failure behavior**: BLOCKED on `PQ-4` for resumption and retake. Independent of it: given a Team Member and an exam not assigned to them, when they request it or submit against it, then the request is denied without confirming whether that exam exists (FR-5.6, SEC-AUTHZ-8, SEC-AUTHZ-7).
3. **AC-03 — Prohibited behavior**: Given an attempt belonging to another team member, when a Team Member submits against its identifier, then it MUST NOT succeed (SEC-AUTHZ-8). Given an assignment to a deactivated member, no new attempt MUST be startable (SEC-BIZ-3). Both hold regardless of how `PQ-4` is answered.

## Failure Behavior

- **On Invalid Input**: Reject the submission; record no attempt result and no score (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; return no exam content (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without disclosing the exam's existence or content (SEC-AUTHZ-7, SEC-AUTHZ-8)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; an attempt MUST NOT be marked complete without its score, nor scored without its audit entry (SEC-ERR-2)
- **Logging / Audit**: Attempt start, submission and denial logged with actor, action, target and timestamp (SEC-LOG-2); answers and answer keys MUST NOT be logged (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — repeated-attempt thresholds depend on `PQ-4` and `PQ-10`

## Test Strategy

- **Unit Tests**: The assignment predicate; the attempt-ownership predicate; BLOCKED on `PQ-4` for the completeness, resumption and retake predicates
- **Integration Tests**: BLOCKED on `PQ-4` — what a second attempt should do is the unresolved question
- **Security Tests**: Submitting an unassigned exam identifier (SEC-AUTHZ-8); submitting against another member's attempt; resubmitting a completed attempt (SEC-AUTHZ-8, with the expected outcome BLOCKED on `PQ-4`); starting an attempt for a deactivated member (SEC-BIZ-3); request-rate and request-size limits on submission (SEC-HTTP-5, itself pending `PQ-10`)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-02's unassigned clause and AC-03 by the SEC-AUTHZ-8 suite; AC-01 and the rest of AC-02 deferred with the criteria themselves
- **Coverage Target**: Positive and negative coverage on assignment and ownership; completeness coverage deferred
- **Required Test Environment**: The `UT-10.1` fixture with exams assigned to some members and not others, and at least one deactivated member holding an assignment

## Dependencies

- **Upstream Requirements**: REQ-EXAM-020, REQ-EXAM-030, REQ-AUTH-060
- **Downstream Requirements**: REQ-EXAM-050
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Assessment owns attempts (DR-3). The rule is enforced at the API regardless of what the client offers (SEC-BOUND-1).
- **Prohibited Approaches**: Trusting an attempt-state value from the request; hiding unassigned exams in the client as the only control (DR-1); resolving the retake policy in code rather than in `REQUIREMENTS.md` or `SECURITY.md`
- **Implementation Guidance**: None on attempt validity while blocked. Note that answering `PQ-4` also bears on `OQ-2`, since a manual review step or a pass threshold would change what "completed" means.
- **AI Development Guidance**: `CLAUDE.md`; do not implement the attempt-validity semantics while BLOCKED
- **Required Human Review**: Product owner to answer `PQ-4`; human security review before merge — authorization (`CLAUDE.md`)
- **Open Decisions**: **`PQ-4` (blocking)** — `SQ-11` in `SECURITY.md` and the matching `UNKNOWN` in `ARCHITECTURE.md` Assessment: are exam attempts subject to proctoring, timing or retake constraints? `SECURITY.md` states that without a policy, SEC-AUTHZ-8 cannot fully specify what a valid attempt is and answer-key confidentiality across repeated attempts is unbounded. `OQ-2` (per-question weights, pass threshold, manual review) is recorded alongside it.
- **Estimated effort**: Not estimated while blocked — a resumable, timed or retakeable attempt is materially more work than a single-shot one.
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — attempt authorization is the gate on answer-key exposure over time; to be confirmed once `PQ-4` fixes the policy.
