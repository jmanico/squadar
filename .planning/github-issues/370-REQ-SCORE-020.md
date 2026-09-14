# [REQ-SCORE-020] Reject any score that is not an integer from 1 to 10

## Metadata

- **ID**: REQ-SCORE-020
- **Title**: Reject any score that is not an integer from 1 to 10
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Security
- **Source / Parent**: REQ-SCORE-000; `REQUIREMENTS.md` FR-4.2, FR-4.3; `SECURITY.md` SEC-INPUT-2, SEC-INPUT-3

## Requirement

- **Statement**: A skill score MUST be an integer from 1 to 10 inclusive; the system MUST reject any other value and MUST NOT record it, partially record it, or allow it to supersede an existing current score; and the API MUST NOT accept a client-supplied value for any server-derived field.
- **Rationale**: FR-4.2 and FR-4.3 fix the scale and the rejection. SEC-INPUT-2 adds the crucial detail that a rejected score must not disturb the existing current score, and SEC-INPUT-3 closes the mass-assignment path on the derived fields.
- **Assumptions**: FR-4.2's "integers only" is marked **(assumed)** in `REQUIREMENTS.md` and stands.
- **Out of Scope**: The storage constraint (REQ-SCORE-010); provenance stamping (REQ-SCORE-040); which actors may write a score at all (REQ-SCORE-070, blocked; REQ-AUTH-060 for the role rules).
- **Design Traceability**: `DESIGN.md` — Components (Inputs: score entry accepts only integers 1–10 and states that range in helper text before the user errs), Form feedback and errors (the message names what is wrong and what to do — "Score must be a whole number from 1 to 10").
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment — validates and records scores as integers 1–10; DR-1 (the client's range hint is a courtesy layer only).
- **Security Traceability**: SEC-INPUT-1, SEC-INPUT-2, SEC-INPUT-3, SEC-BOUND-1, SEC-ERR-1, SEC-ERR-2.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; REST API; `shared/`; Web Client
- **Interfaces / Operations**: Every score write path — assessor rating, self-assessment, exam-derived score, bulk import
- **Actors**: Administrator, Assessor, Team Member
- **Preconditions**: REQ-FOUND-020 and REQ-SCORE-010 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Integrity
- **Control Layers**: Input Validation, Business-Rule Validation
- **Threat References**: STRIDE — Tampering; OWASP Top 10:2025 Injection; CWE-20 Improper Input Validation; CWE-1284 Improper Validation of Specified Quantity in Input; CWE-915 Improperly Controlled Modification of Dynamically-Determined Object Attributes
- **Abuse / Misuse Case**: Submitting 0, 11, 5.5, `"5"`, `null` or `NaN` and having it coerced into a valid score; submitting an invalid score that nonetheless clears the existing current score; submitting a `method`, `source`, `recordedDate` or audit field alongside the score and having the server honour it.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: The score value, its type, and every other field in the payload including ones the server derives
- **Authoritative Enforcement Point**: Assessment behind the REST API, applying the shared schema from REQ-FOUND-020 (SEC-BOUND-1)
- **Independent Verification**: Tests submit values directly to the API with both clients bypassed, and assert the prior current score is unchanged (SEC-INPUT-2)
- **Zero Trust Relevance**: N/A — `REQUIREMENT_TEMPLATE.md` warns against using Zero Trust as a synonym for input validation

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`; the applicable chapter is Validation and Business Logic
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: The CWE identifiers above are cited because they name exactly the two failure classes SEC-INPUT-2 and SEC-INPUT-3 guard against — range coercion and mass assignment.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a permitted actor, when they submit an integer from 1 to 10 for a member and skill, then the score is accepted and recorded (FR-4.2).
2. **AC-02 — Boundary or failure behavior**: Given a member whose current score for a skill is 6, when 0, 11, 5.5, `"5"`, `null`, `NaN` or an absent value is submitted, then each is rejected with a product-term reason, nothing is recorded, and the current score is still 6 (FR-4.3, SEC-INPUT-2).
3. **AC-03 — Prohibited behavior**: Given a score payload that also carries a scoring method, source assessor or exam, recorded date, or an audit field, when it is submitted, then those client-supplied values MUST NOT take effect — the server's own values prevail (SEC-INPUT-3).

## Failure Behavior

- **On Invalid Input**: Reject rather than coerce; no record, no partial record, and no supersession of the existing current score (SEC-INPUT-2)
- **On Authentication Failure**: Refuse (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming the member or score exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; no partially applied write (SEC-ERR-2)
- **Logging / Audit**: Log the endpoint and the failing field name; the submitted score value MUST NOT be logged (SEC-LOG-3). A successful write produces the audit entry REQ-SCORE-060 defines
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: The range predicate at 0, 1, 10, 11; type rejection for `"5"`, 5.5, `null`, `NaN`, absent, arrays and objects; the derived-field stripping rule
- **Integration Tests**: Each rejection asserted at the API with the prior current score re-read afterwards and found unchanged
- **Security Tests**: The full SEC-INPUT-2 value set — 0, 11, 5.5, `"5"`, `null`, `NaN`, absent — asserting the prior current score is unchanged; mass-assignment tests submitting each derived field and asserting the server value prevails (SEC-INPUT-3); a direct API submission bypassing both clients (SEC-BOUND-1)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the accepted-value test; AC-02 by the SEC-INPUT-2 value set; AC-03 by the mass-assignment suite
- **Coverage Target**: Every value in the SEC-INPUT-2 set and every server-derived field in the SEC-INPUT-3 set, positive and negative
- **Required Test Environment**: The `UT-10.1` fixture with a member holding a known current score, so the "unchanged" assertion is meaningful

## Dependencies

- **Upstream Requirements**: REQ-FOUND-020, REQ-SCORE-010, REQ-UIKIT-050
- **Downstream Requirements**: REQ-SCORE-040, REQ-SCORE-050, REQ-SCORE-070, REQ-EXAM-050, REQ-PORT-020
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: The rule lives server-side; the client's helper text and input constraint are a courtesy layer duplicated behind the API boundary (DR-1).
- **Prohibited Approaches**: Coercing `"5"` to 5; clamping 11 to 10; treating an absent value as a deletion of the current score; accepting any server-derived field from the client
- **Implementation Guidance**: Reuse the score schema from REQ-FOUND-020 rather than restating the range here, so the import path (REQ-PORT-020) and the interactive path cannot diverge, which is exactly what SEC-INPUT-4 requires.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — input handling (`CLAUDE.md`)
- **Open Decisions**: None
- **Estimated effort**: 0.5–1 engineer-day; 250–450 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — small but security-critical: the dangerous behaviors are coercion and a rejected write that still disturbs existing state, both of which pass a naive test suite.
