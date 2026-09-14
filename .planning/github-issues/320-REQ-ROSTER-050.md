# [REQ-ROSTER-050] Personal-data deletion on request

> **BLOCKED — do not implement.** Blocked on `PQ-3`. See **Open Decisions**.

## Metadata

- **ID**: REQ-ROSTER-050
- **Title**: Personal-data deletion on request
- **Version**: 0.1.0
- **Status**: Draft
- **Owner**: Squadar product and engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Privacy
- **Source / Parent**: REQ-ROSTER-000; `REQUIREMENTS.md` FR-8.4, NFR-9.6; `SECURITY.md` SEC-DATA-3, `SQ-6`

## Requirement

- **Statement**: An Administrator MUST be able to delete a team member's personal data on request, and after deletion that member and their scores MUST NOT appear in any chart, list, ranked view, export or search result.
- **Rationale**: FR-8.4 states the outcome and SEC-DATA-3 extends it to every surface including cached and derived views. What is unresolved is the mechanism — erasure or irreversible anonymization — and what happens to the audit entries NFR-9.6 requires, which is a direct conflict between two stated requirements.
- **Assumptions**: None — the mechanism is recorded as unresolved rather than assumed.
- **Out of Scope**: Deactivation (REQ-ROSTER-020), which retains history by design and is a different operation.
- **Design Traceability**: `DESIGN.md` — Components (Buttons: the destructive variant, filled `error`, is reserved for deletion and deactivation), Form feedback and errors (destructive confirmation uses `error`).
- **Architecture Traceability**: `ARCHITECTURE.md` Roster — personal-data deletion on request; whether deletion is erasure or irreversible anonymization and its effect on audit entries is `TO BE DECIDED`; deletion events consumed by Assessment; DR-3, DR-5.
- **Security Traceability**: SEC-DATA-3, SEC-DATA-6, SEC-AUTHZ-6, SEC-LOG-1, SEC-LOG-2, SEC-LOG-4, SEC-ERR-2.

## Scope

- **Applies To**: Multiple
- **Components**: Roster; Assessment; Chart Data Service; Bulk Import / Export; REST API
- **Interfaces / Operations**: Deletion request; the deletion event consumed by Assessment; every surface that can return member data
- **Actors**: Administrator; the team member who requested deletion
- **Preconditions**: The caller is an Administrator and the member exists
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`; if GDPR or CCPA apply, erasure is a right with defined bounds, which would itself constrain the answer to `PQ-3`

## Security Context

- **Security Objectives**: Privacy, Confidentiality, Accountability
- **Control Layers**: Data Protection, Authorization, Logging and Monitoring
- **Threat References**: STRIDE — Information Disclosure, Repudiation; OWASP Top 10:2025 Broken Access Control; CWE-212 Improper Removal of Sensitive Information Before Storage or Transfer
- **Abuse / Misuse Case**: A deleted member still reachable through a ranked list, an export, a cached chart dataset or a search result; deletion used to destroy the audit trail NFR-9.6 requires; a non-Administrator triggering deletion.
- **Trust Boundary**: Clients → REST API; and internally, Roster → Assessment via the deletion event
- **Untrusted Inputs or Assertions**: The member identifier in a deletion request
- **Authoritative Enforcement Point**: Roster, publishing a deletion event Assessment consumes (DR-5)
- **Independent Verification**: A post-deletion sweep of every surface that can return member data, including cached and derived views (SEC-DATA-3)
- **Zero Trust Relevance**: N/A — this is a data-lifecycle obligation, not a resource-access policy decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13` (`SQ-1`); the applicability of GDPR or CCPA would determine whether erasure is a legal right with defined limits or a product feature
- **Other**: N/A
- **Mapping Basis**: Regulatory scope is the decisive mapping here and it is unresolved, which is part of why this issue is blocked.

## Acceptance Criteria

Acceptance criteria cannot be written. FR-8.4 requires the member and their scores to disappear from
every surface; NFR-9.6 requires an audit entry for every score created, changed or deleted, naming
who made the change. Whether deletion is erasure or irreversible anonymization decides whether those
audit entries survive, and in what form. Both readings are defensible and the documents do not choose
between them. Writing criteria now would resolve `PQ-3` by implication.

1. **AC-01 — Expected behavior**: BLOCKED on `PQ-3`.
2. **AC-02 — Boundary or failure behavior**: BLOCKED on `PQ-3`.
3. **AC-03 — Prohibited behavior**: Given a deleted member, when any chart, list, ranked view, export or search result is produced, then that member and their scores MUST NOT appear in it (FR-8.4, SEC-DATA-3). This criterion holds regardless of how `PQ-3` is answered; what it does not settle is the state of the audit trail.

## Failure Behavior

- **On Invalid Input**: Reject a malformed deletion request; delete nothing (SEC-INPUT-1)
- **On Authentication Failure**: Refuse (SEC-AUTHN-1)
- **On Authorization Failure**: Deny — deletion is Administrator-only (SEC-AUTHZ-6); do not confirm whether the named member exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; a deletion that reaches Roster but not Assessment is a partially applied change and is prohibited (SEC-ERR-2, DR-5)
- **Logging / Audit**: The deletion request itself is a security-relevant event and is logged with actor, action, target and timestamp (SEC-LOG-2). What happens to the member's existing score audit entries is BLOCKED on `PQ-3`, and SEC-LOG-4 makes those entries non-deletable through any product interface — which is precisely the tension to resolve.
- **Alerting**: TO BE DECIDED

## Test Strategy

- **Unit Tests**: BLOCKED on `PQ-3` — the deletion mechanism determines what to assert
- **Integration Tests**: The deletion event published by Roster and consumed by Assessment (DR-5), once the mechanism is known
- **Security Tests**: The post-deletion sweep of every surface that can return member data, including cached and derived views (SEC-DATA-3); the Administrator-only check (SEC-AUTHZ-6); an audit-mutation attempt asserting SEC-LOG-4 still holds after deletion
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-03 by the post-deletion sweep; AC-01 and AC-02 deferred with the criteria themselves
- **Coverage Target**: Every surface that can return member data covered by the post-deletion sweep
- **Required Test Environment**: The `UT-10.1` fixture with a member who has scores, exam attempts and audit entries

## Dependencies

- **Upstream Requirements**: REQ-ROSTER-020, REQ-SCORE-060, REQ-AUTH-060
- **Downstream Requirements**: None
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Roster owns members; Assessment owns scores and audit entries; deletion crosses that boundary as an event, not a direct write (DR-3, DR-5).
- **Prohibited Approaches**: A deletion that only hides the member from lists while leaving them reachable through a ranked view, an export or a cached dataset (SEC-DATA-3); deleting audit entries through a product interface (SEC-LOG-4) — unless `PQ-3` explicitly decides otherwise and `SECURITY.md` is amended in the same change
- **Implementation Guidance**: None while blocked. Note that answering `PQ-3` will almost certainly require a change to `SECURITY.md` or `REQUIREMENTS.md` — `CLAUDE.md` requires that change to land in the same commit as the implementation rather than the decision living only in code.
- **AI Development Guidance**: `CLAUDE.md`; do not implement while BLOCKED
- **Required Human Review**: Product owner and a privacy or legal reviewer to answer `PQ-3`; human security review before merge
- **Open Decisions**: **`PQ-3` (blocking)** — `SQ-6` in `SECURITY.md` and the matching `TO BE DECIDED` in `ARCHITECTURE.md` Roster: is FR-8.4 deletion an irreversible erasure or an anonymization, and what happens to the audit entries NFR-9.6 requires and SEC-LOG-4 makes append-only? Also recorded: `PQ-13` (`SQ-1`), since regulatory applicability bears on the answer.
- **Estimated effort**: Not estimated while blocked — erasure and anonymization differ materially in scope.
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — a cross-component data-lifecycle change that must hold across every derived and cached view; to be confirmed once `PQ-3` fixes the mechanism.
