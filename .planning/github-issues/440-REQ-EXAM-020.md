# [REQ-EXAM-020] Assign an exam and send its invitation through the notification adapter

## Metadata

- **ID**: REQ-EXAM-020
- **Title**: Assign an exam and send its invitation through the notification adapter
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-EXAM-000; `REQUIREMENTS.md` FR-5.5; `SECURITY.md` SEC-AUTHN-8, SEC-EXT-1, SEC-EXT-3

## Requirement

- **Statement**: An Assessor or Administrator MUST be able to assign an exam to one or more team members, and the invitation MUST be sent through an adapter owned by Outbound Notification, carrying the minimum content needed, with any link it contains single-use, time-bounded, unguessable, bound to the intended recipient account, and conferring no session beyond the action it authorizes.
- **Rationale**: FR-5.5 states the assignment. `REQUIREMENTS.md` names outbound transactional email for exam invitations as the system's only external integration, and SEC-AUTHN-8 and SEC-EXT-3 set what such a message may carry and how long its link may live.
- **Assumptions**: An Assessor may assign only to members on their assigned teams, by FR-1.5 and SEC-AUTHZ-4, even though FR-5.5 does not restate the scope.
- **Out of Scope**: Whether a given assignment permits an attempt, and retake policy (REQ-EXAM-040, blocked on `PQ-4`); the exam payload delivered to the assignee (REQ-EXAM-030).
- **Design Traceability**: `DESIGN.md` — Components (Inputs: selection of team members uses checkable list items with a visible count; Buttons: a slow action shows a busy state), Form feedback and errors.
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment — owns exam assignment; Outbound Notification — a delivery edge, not a decision point, sending what a domain component asks it to send; DR-3, DR-5, DR-6.
- **Security Traceability**: SEC-AUTHN-8, SEC-EXT-1, SEC-EXT-2, SEC-EXT-3, SEC-EXT-4, SEC-AUTHZ-4, SEC-AUTHZ-5, SEC-BIZ-3, SEC-LOG-2, SEC-LOG-3.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; Outbound Notification; the mail-provider adapter; REST API; Web Client
- **Interfaces / Operations**: Exam assignment to one or more members; invitation dispatch; assignment list
- **Actors**: Administrator, Assessor (write); Team Member (recipient); the mail provider
- **Preconditions**: REQ-EXAM-010 is Verified; the exam exists; each target member is active (FR-2.3)
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data — the message is addressed to an identified individual
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Authorization, Confidentiality, Authenticity
- **Control Layers**: Authorization, Authentication, Business-Rule Validation, Other
- **Threat References**: STRIDE — Elevation of Privilege, Information Disclosure, Spoofing; OWASP Top 10:2025 Broken Access Control; CWE-640 Weak Password Recovery Mechanism for Forgotten Password; CWE-201 Insertion of Sensitive Information Into Sent Data
- **Abuse / Misuse Case**: An invitation link reused after the first use, used after expiry, or used by a different account; an Assessor assigning an exam to a member outside their teams; an invitation carrying a score, an exam answer or a credential in its body; a server-side fetch of a URL taken from assignment data.
- **Trust Boundary**: Clients → REST API; API → mail provider
- **Untrusted Inputs or Assertions**: Member identifier lists, the exam identifier, and every response from the mail provider
- **Authoritative Enforcement Point**: Assessment for the assignment decision; Identity & Access for the link's single-use, time-bounded, account-bound properties (SEC-AUTHN-8)
- **Independent Verification**: A test that a link fails on second use, after expiry, and for a different account (SEC-AUTHN-8); inspection of every message template against a permitted-field list (SEC-EXT-3)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — assignment authority depends on the Assessor's current team assignment

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no control mapping verified against a specific catalog release
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: CWE-640 is cited because an emailed link that authorizes an action carries the same failure modes as a recovery link — reuse, expiry and binding.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an Administrator or an Assessor assigning within their teams, when they assign an exam to three members, then three assignments exist and an invitation is dispatched to each through the Outbound Notification adapter (FR-5.5).
2. **AC-02 — Boundary or failure behavior**: Given an invitation link, when it is used a second time, after its expiry, or by an account other than the intended recipient, then it MUST NOT authorize the action, and it MUST NOT have conferred a session beyond that action at any point (SEC-AUTHN-8).
3. **AC-03 — Prohibited behavior**: Given an Assessor, when they assign an exam to a member outside their assigned teams, then it MUST NOT succeed (FR-1.5, SEC-AUTHZ-4); and given any invitation message, it MUST NOT contain a score, an exam answer or a credential (SEC-EXT-3).

## Failure Behavior

- **On Invalid Input**: Reject with the reason named; create no assignment and dispatch nothing (SEC-INPUT-1)
- **On Authentication Failure**: Refuse (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the named member or exam exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: A mail-provider failure MUST NOT roll back the assignment — the assignment stands and the dispatch is retried or reported; no vendor error shape crosses out of the adapter (DR-6, SEC-EXT-1). Retry and bounce handling are `TO BE DECIDED` in `ARCHITECTURE.md` Outbound Notification
- **On System Error**: Roll back the assignment write; no assignment recorded for some members of a batch and not others (SEC-ERR-2)
- **Logging / Audit**: Assignment logged with actor, action, target and timestamp (SEC-LOG-2); link values, exam content and score values MUST NOT be logged (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — dispatch-failure alerting depends on `PQ-9`

## Test Strategy

- **Unit Tests**: Assignment construction for one and many members; the Assessor team-scope predicate; link generation properties — unguessable, bound, time-bounded, single-use
- **Integration Tests**: Assignment followed by dispatch through a mail-provider simulator; a provider failure asserting the assignment survives (DR-6)
- **Security Tests**: Link failure on second use, after expiry and for a different account (SEC-AUTHN-8); an Assessor assigning out-of-team (SEC-AUTHZ-4); a Viewer attempting assignment (SEC-AUTHZ-5); assignment naming a deactivated member (SEC-BIZ-3); message-template review against a permitted-field list (SEC-EXT-3); malformed, oversized and error responses from the adapter asserting fail-closed behavior (SEC-EXT-2); internal and metadata-endpoint URLs in any dereferenceable field (SEC-EXT-4)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the assignment and dispatch tests; AC-02 by the link-property suite; AC-03 by the SEC-AUTHZ-4 tests and the template review
- **Coverage Target**: Positive and negative coverage on the assignment authorization and on each link property
- **Required Test Environment**: The `UT-10.1` fixture with an Assessor assigned to a strict subset of teams; a mail-provider simulator that can be made to fail

## Dependencies

- **Upstream Requirements**: REQ-EXAM-010, REQ-ROSTER-030, REQ-AUTH-050, REQ-AUTH-060
- **Downstream Requirements**: REQ-EXAM-030, REQ-EXAM-040
- **External Dependencies**: A mail provider — `TO BE DECIDED` in `ARCHITECTURE.md`; reached only through an adapter (DR-6, SEC-EXT-1)
- **Dependency Assumptions**: The provider delivers or reports; it is not assumed to have delivered, and its responses are treated as untrusted input (SEC-EXT-2). Whether sending is synchronous or queued is `TO BE DECIDED`.
- **Failure Impact**: An unavailable provider delays invitations; assignments still exist and a member who reaches the exam by other means is unaffected.

## Implementation Notes

- **Constraints**: Outbound Notification is a delivery edge, not a decision point — it sends what Assessment asks it to send and makes no authorization decision of its own (`ARCHITECTURE.md`).
- **Prohibited Approaches**: Sending the exam content or its answers in the message (SEC-EXT-3); a link that establishes a full session; a link whose value is guessable or reusable; a vendor error type leaking into Assessment (SEC-EXT-1)
- **Implementation Guidance**: Link lifetime is `TO BE DECIDED` in SEC-AUTHN-8 — choose one, record it in `SECURITY.md` in the same change, and test both sides of it.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — authentication, authorization and an external integration (`CLAUDE.md`)
- **Open Decisions**: Link lifetime (`TO BE DECIDED`, SEC-AUTHN-8); mail provider, retry, bounce handling and synchronous vs. queued sending (`TO BE DECIDED`, `ARCHITECTURE.md`). None blocks the behavior; each must be recorded when chosen.
- **Estimated effort**: 1.5–2 engineer-days; 500–800 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — an emailed link that authorizes an action is a credential in all but name, and its four required properties each fail silently if omitted.
