# [REQ-SCORE-060] Append-only score audit trail readable only by an Administrator

## Metadata

- **ID**: REQ-SCORE-060
- **Title**: Append-only score audit trail readable only by an Administrator
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Security
- **Source / Parent**: REQ-SCORE-000; `REQUIREMENTS.md` NFR-9.6; `SECURITY.md` SEC-LOG-1, SEC-LOG-3, SEC-LOG-4

## Requirement

- **Statement**: Every score create, change and delete MUST produce an audit entry naming the acting user, the affected member and skill, the method and the timestamp; the trail MUST be retrievable only by an Administrator; and entries MUST NOT be modifiable or deletable through any product interface.
- **Rationale**: NFR-9.6 requires the audit trail and SEC-LOG-1 fixes its fields and its Administrator-only access. SEC-LOG-4 makes it append-only, which is what makes it evidence rather than mutable state.
- **Assumptions**: NFR-9.6 is marked **(assumed)** in `REQUIREMENTS.md` and stands.
- **Out of Scope**: Security-event logging for authentication, session and account changes (SEC-LOG-2), which REQ-AUTH-050 owns. What happens to audit entries when a member's personal data is deleted — `PQ-3`, blocking REQ-ROSTER-050.
- **Design Traceability**: `DESIGN.md` — Layout and Spacing (Density: the audit view is a table, compact), Typography (Caption for metadata), Accessibility (the table is keyboard-pageable).
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment — writes an audit entry for every score create, change or delete; owns score audit entries; DR-3.
- **Security Traceability**: SEC-LOG-1, SEC-LOG-3, SEC-LOG-4, SEC-AUTHZ-1, SEC-AUTHZ-5, SEC-AUTHZ-6, SEC-ERR-2, SEC-DATA-6.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; Relational Data Store; REST API; Web Client
- **Interfaces / Operations**: Audit entry write on every score mutation; audit trail read
- **Actors**: Administrator (read); all score-writing actors are recorded as subjects
- **Preconditions**: REQ-SCORE-040 and REQ-SCORE-050 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data — an entry names both the acting user and the assessed member
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`; retention for audit entries is `TO BE DECIDED` in SEC-DATA-6

## Security Context

- **Security Objectives**: Accountability, Integrity, Confidentiality
- **Control Layers**: Logging and Monitoring, Authorization, Data Protection
- **Threat References**: STRIDE — Repudiation, Tampering, Information Disclosure; OWASP Top 10:2025 Security Logging and Monitoring Failures; CWE-778 Insufficient Logging; CWE-117 Improper Output Neutralization for Logs
- **Abuse / Misuse Case**: A score changed with no audit entry, so the change cannot be attributed; an audit entry edited or deleted through a product interface to conceal a change; a non-Administrator reading the trail and learning individuals' score movements; score values written into the trail and then into general logs, widening exposure.
- **Trust Boundary**: Clients → REST API; and the audit store, which no product interface may mutate
- **Untrusted Inputs or Assertions**: Audit query parameters; any client attempt to write or amend an entry
- **Authoritative Enforcement Point**: Assessment, writing the entry in the same transaction as the score mutation, and the audit store, which accepts appends only (SEC-LOG-4)
- **Independent Verification**: A test attempting audit mutation through every role and asserting refusal (SEC-LOG-4); `.claude/hooks/protect-files.sh` already enforces append-only on audit and security logs at the development-tool level
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 7 — the system collects information about the state of assets and access to inform policy

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`; the applicable chapter is Security Logging and Error Handling
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no control mapping verified against a specific catalog release
- **NIST SP 800-207**: §2.1 tenet 7
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: Tenet 7 is cited because the audit trail is the system's record of access and change, which SP 800-207 treats as an input to policy rather than an afterthought.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given any score create, change or delete, when it completes, then exactly one audit entry exists naming the acting user, the affected member, the skill, the method and the timestamp, written in the same transaction as the score mutation (NFR-9.6, SEC-LOG-1, SEC-ERR-2).
2. **AC-02 — Boundary or failure behavior**: Given any non-Administrator role, when they request the audit trail, then the request is denied and no entry is returned (SEC-LOG-1, SEC-AUTHZ-5).
3. **AC-03 — Prohibited behavior**: Given any role including Administrator, when an attempt is made to modify or delete an audit entry through any product interface, then it MUST NOT succeed (SEC-LOG-4); and an individual's score values MUST NOT appear in general application logs (SEC-LOG-3).

## Failure Behavior

- **On Invalid Input**: Reject a malformed audit query; return no entries (SEC-INPUT-1)
- **On Authentication Failure**: Refuse (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether entries exist for the named member (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; an exam scored without its audit entry is a prohibited partial state (SEC-ERR-2)
- **Logging / Audit**: This issue is the audit mechanism. Entries record identifiers rather than personal content, and MUST NOT contain credentials, session tokens, exam answer keys or an individual's score values in the general log stream (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — an alert on audit-write failure would be appropriate, but the destination depends on `PQ-9`

## Test Strategy

- **Unit Tests**: Entry construction and field completeness; the one-entry-per-mutation invariant; log-line construction asserting no score value is included
- **Integration Tests**: An audit entry asserted per score mutation across every write path including the exam path (SEC-LOG-1); a failure-injection test asserting a score cannot be recorded without its entry (SEC-ERR-2)
- **Security Tests**: An attempted audit mutation from every role asserting refusal (SEC-LOG-4); the non-Administrator read sweep (SEC-LOG-1); a log-scrubbing test exercising the authentication, exam and scoring paths and asserting absence of credentials, tokens, answer keys and score values (SEC-LOG-3)
- **Compliance Tests / Evidence**: TO BE DECIDED — retention evidence depends on SEC-DATA-6 and `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the per-mutation entry tests; AC-02 by the role sweep; AC-03 by the mutation-attempt tests and the log-scrubbing test
- **Coverage Target**: Every score write path produces an entry; every role is covered for read and for mutation attempt
- **Required Test Environment**: The `UT-10.1` fixture with an Administrator account and at least one account of each other role

## Dependencies

- **Upstream Requirements**: REQ-SCORE-040, REQ-SCORE-050, REQ-AUTH-060
- **Downstream Requirements**: REQ-EXAM-050, REQ-ROSTER-050
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: The entry is written in the same transaction as the score mutation — SEC-ERR-2 names "an exam scored without an audit entry" as a prohibited partial state, so a deferred or queued write does not satisfy this.
- **Prohibited Approaches**: An update or delete path on the audit store exposed through any product interface (SEC-LOG-4); writing score values into the general log stream (SEC-LOG-3); a best-effort audit write that can fail silently
- **Implementation Guidance**: Append-only means the product interface offers no mutation, not merely that none is called. `.claude/hooks/protect-files.sh` already models this rule at the development-tool level; the runtime store should carry the same property.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — logging and data protection (`CLAUDE.md`)
- **Open Decisions**: `PQ-13` (retention, SEC-DATA-6) and `PQ-3` (the interaction between FR-8.4 deletion and this trail) are recorded. Neither blocks this issue; `PQ-3` blocks REQ-ROSTER-050.
- **Estimated effort**: 1–1.5 engineer-days; 350–600 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — accountability evidence whose value depends on completeness and immutability, with a transactional coupling to every score write path.
