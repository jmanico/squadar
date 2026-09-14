# [REQ-SKILL-020] Retire a skill, retaining history and excluding it from new assessments

## Metadata

- **ID**: REQ-SKILL-020
- **Title**: Retire a skill, retaining history and excluding it from new assessments
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Medium
- **Requirement Type**: Functional
- **Source / Parent**: REQ-SKILL-000; `REQUIREMENTS.md` FR-3.2, FR-3.4; `SECURITY.md` SEC-BIZ-3

## Requirement

- **Statement**: An Administrator MUST be able to retire a skill; the system MUST retain existing scores for a retired skill and MUST NOT offer that skill for new assessments, enforced at the API regardless of what the client offers.
- **Rationale**: FR-3.4 keeps a retired skill's history readable while removing it from use. SEC-BIZ-3 makes the exclusion server-side, so a direct API call cannot record against it.
- **Assumptions**: None.
- **Out of Scope**: Skill creation and rename (REQ-SKILL-010); the axis candidate list, which must exclude retired skills and is REQ-SKILL-030.
- **Design Traceability**: `DESIGN.md` — Components (Buttons: the destructive variant is reserved for deletion and deactivation, which retirement is the catalog analogue of; disabled is never the only signal that an action is unavailable — say why in adjacent text).
- **Architecture Traceability**: `ARCHITECTURE.md` Skill Catalog — retired skills remain scoreable in history but are not offered for new assessments; DR-3.
- **Security Traceability**: SEC-BIZ-3, SEC-AUTHZ-5, SEC-AUTHZ-6, SEC-INPUT-1, SEC-LOG-2.

## Scope

- **Applies To**: Multiple
- **Components**: Skill Catalog; Assessment; REST API; Web Client
- **Interfaces / Operations**: Skill retire; the assessment write path's active-skill check; historical score read for a retired skill
- **Actors**: Administrator (write); all roles (read)
- **Preconditions**: REQ-SKILL-010 is Verified
- **Data Classification**: Internal
- **Personal or Regulated Data**: None — the skill record itself carries no personal data, though the scores it is referenced by do
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Integrity, Authorization
- **Control Layers**: Authorization, Business-Rule Validation
- **Threat References**: STRIDE — Tampering; OWASP Top 10:2025 Broken Access Control; CWE-863 Incorrect Authorization
- **Abuse / Misuse Case**: A score recorded against a retired skill by calling the API directly, bypassing a client that hides it; retirement implemented as a delete, losing the history FR-3.4 requires; a non-Administrator retiring a skill in use.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Skill identifiers and retirement-state values in a request
- **Authoritative Enforcement Point**: Skill Catalog for the state; Assessment for refusing a write against a retired skill (SEC-BIZ-3)
- **Independent Verification**: Direct API write attempts naming a retired skill, run without a client (SEC-BIZ-3)
- **Zero Trust Relevance**: N/A — a business-rule check, not a resource-access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: N/A
- **Mapping Basis**: No standard mapping is verified; the governing rules are FR-3.4 and SEC-BIZ-3.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an Administrator and a skill with recorded scores, when the skill is retired, then those scores remain retrievable and the skill is reported as retired (FR-3.4).
2. **AC-02 — Boundary or failure behavior**: Given a retired skill, when a score is submitted against it directly to the API with no client involved, then the write is refused with the reason stated and no score is recorded (SEC-BIZ-3).
3. **AC-03 — Prohibited behavior**: Given a retired skill, when the catalog is offered for a new assessment or for chart axis selection, then that skill MUST NOT appear among the candidates; and retirement MUST NOT delete the skill record or any score referencing it (FR-3.4).

## Failure Behavior

- **On Invalid Input**: Reject with the reason named; no state change (SEC-INPUT-1)
- **On Authentication Failure**: Refuse (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the named skill exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; a retirement takes effect fully or not at all (SEC-ERR-2)
- **Logging / Audit**: Skill retirement logged with actor, action, target and timestamp (SEC-LOG-2)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: The retirement state transition; the active-skill predicate used by the assessment write path and by the candidate list
- **Integration Tests**: Historical scores for a retired skill still readable through the score and chart routes; the skill absent from new-assessment options
- **Security Tests**: Direct API write attempts naming a retired skill (SEC-BIZ-3); the role sweep over retirement (SEC-AUTHZ-5, SEC-AUTHZ-6)
- **Compliance Tests / Evidence**: N/A
- **Acceptance-Criteria Traceability**: AC-01 by the retire-and-read test; AC-02 by the direct API write test; AC-03 by the candidate-list test and a no-delete assertion
- **Coverage Target**: Positive and negative coverage on the exclusion rule and on the history-retention guarantee
- **Required Test Environment**: The `UT-10.1` fixture, which includes at least one retired skill with prior scores

## Dependencies

- **Upstream Requirements**: REQ-SKILL-010, REQ-AUTH-060
- **Downstream Requirements**: REQ-SKILL-030, REQ-SCORE-020, REQ-EXAM-010, REQ-CHART-010
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Retirement is a status on the skill, not a deletion — that is what makes FR-3.4 hold without a second mechanism.
- **Prohibited Approaches**: Deleting the skill or cascading to its scores; enforcing the exclusion only by hiding retired skills in the client (DR-1); reusing a retired skill's name check in a way that blocks a new active skill of the same name, which FR-3.3 scopes to active skills only
- **Implementation Guidance**: The same active-entity predicate pattern used for deactivated members in REQ-ROSTER-020 applies here; keeping the two consistent makes SEC-BIZ-3's single rule one mechanism rather than two.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/spec-auditor.md` before the pull request
- **Required Human Review**: Architecture reviewer for consistency with the member deactivation model
- **Open Decisions**: None
- **Estimated effort**: 0.5 engineer-day; 150–300 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a single state transition and one server-side exclusion rule, mirroring an existing pattern.
