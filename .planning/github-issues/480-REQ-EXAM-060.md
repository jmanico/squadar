# [REQ-EXAM-060] Use the updated score everywhere after reassessment

## Metadata

- **ID**: REQ-EXAM-060
- **Title**: Use the updated score everywhere after reassessment
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-EXAM-000; `REQUIREMENTS.md` FR-5.10; `ARCHITECTURE.md` Primary Flow 3

## Requirement

- **Statement**: A team member MUST be able to be reassessed on a skill by any supported method, and after reassessment the updated score MUST be used wherever the current score is displayed, including in radar charts.
- **Rationale**: FR-5.10 closes the loop between recording and display. `ARCHITECTURE.md` notes that subsequent chart reads pick up the new current score automatically — this issue is what makes "automatically" true rather than assumed, by proving no surface holds a stale copy.
- **Assumptions**: None.
- **Out of Scope**: The supersession mechanism itself (REQ-SCORE-050); the exam scoring path (REQ-EXAM-050); whether a self-assessment participates in the current score (`PQ-5`, blocking REQ-SCORE-070).
- **Design Traceability**: `DESIGN.md` — Charts (the chart reflects the current selection and its data), Components (Form feedback and errors: the confirmation persists until the user moves on rather than vanishing on a timer), Accessibility (Reduced motion: an updated series appears at its final position rather than animating in).
- **Architecture Traceability**: `ARCHITECTURE.md` Primary Flow 3 — subsequent chart reads pick up the new current score automatically; Chart Data Service; DR-7 (one dataset behind chart and table).
- **Security Traceability**: SEC-BIZ-2, SEC-DATA-3, SEC-DATA-4, SEC-AUTHZ-3.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; Chart Data Service; REST API; Web Client
- **Interfaces / Operations**: Every surface showing a current score — chart, score table, ranked list, score detail, export
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: REQ-SCORE-050 and REQ-EXAM-050 are Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Integrity
- **Control Layers**: Business-Rule Validation, Data Protection
- **Threat References**: STRIDE — Tampering; CWE-524 Use of Cache Containing Sensitive Information
- **Abuse / Misuse Case**: A cached chart dataset continuing to display a superseded score after reassessment, so a person is shown to colleagues at a measurement they have since improved on. The same caching path is the one SEC-DATA-3 names for deleted members, so a stale-cache defect here is also a privacy defect there.
- **Trust Boundary**: Assessment → Chart Data Service → REST API → clients
- **Untrusted Inputs or Assertions**: N/A for this rule — the risk is internal staleness, not hostile input
- **Authoritative Enforcement Point**: Assessment holds the single current score; every surface reads it rather than holding its own copy (DR-7)
- **Independent Verification**: A test that reassesses and then re-reads every current-score surface, rather than only the one the change was made through
- **Zero Trust Relevance**: N/A

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: CWE-524 is cited because the realistic failure here is a cached derived view rather than a logic error.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a member whose current score for a skill is 6, when they are reassessed to 8 by exam, by assessor rating or by self-assessment, then every surface showing a current score — chart, score table, ranked list, score detail and export — shows 8 on the next read (FR-5.10).
2. **AC-02 — Boundary or failure behavior**: Given a chart dataset read immediately before a reassessment and another read immediately after, when the two are compared, then the second reflects the new score; a cached or derived view MUST NOT serve the superseded value (FR-5.10, SEC-DATA-3's caching principle).
3. **AC-03 — Prohibited behavior**: Given reassessment by any supported method, when the current score is resolved, then the superseded score MUST NOT appear as the current score on any surface, and the superseded score MUST still be present in history (FR-4.6).

## Failure Behavior

- **On Invalid Input**: Handled by REQ-SCORE-020 — an invalid reassessment leaves the current score unchanged, and every surface continues to show the prior value correctly
- **On Authentication Failure**: Refuse; return no score data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming the member exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: A surface that cannot resolve the current score returns an error rather than a stale value (SEC-ERR-1)
- **Logging / Audit**: The reassessment itself is audited by REQ-SCORE-060 (SEC-LOG-1)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Current-score resolution after supersession; cache invalidation keyed on member and skill, if any cache exists
- **Integration Tests**: A reassessment by each of the three methods followed by a read of every current-score surface, asserting the new value in each; the before-and-after chart dataset comparison
- **Security Tests**: A cached-view test asserting no superseded value is served after reassessment — the same mechanism SEC-DATA-3 relies on for deletion; a Team Member reading their own updated score and being denied another individual's (SEC-AUTHZ-3)
- **Compliance Tests / Evidence**: WCAG 2.2 AA — under `prefers-reduced-motion: reduce` an updated series appears at its final position rather than animating in
- **Acceptance-Criteria Traceability**: AC-01 by the all-surfaces read test; AC-02 by the before-and-after comparison; AC-03 by a history assertion alongside the current-score assertion
- **Coverage Target**: Every current-score surface × every reassessment method
- **Required Test Environment**: The `UT-10.1` fixture with a member holding a known current score on a skill that also appears on a chart

## Dependencies

- **Upstream Requirements**: REQ-SCORE-050, REQ-EXAM-050, REQ-CHART-010, REQ-CHART-070, REQ-CHART-080
- **Downstream Requirements**: None
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: DR-7 — the chart and its table come from one dataset, so there is one place for a stale value to hide rather than two. Keep it that way.
- **Prohibited Approaches**: A client-held copy of the current score that survives a reassessment; a cache without invalidation on the member-and-skill key; a surface that computes the current score independently rather than reading the dataset
- **Implementation Guidance**: If any caching is introduced for NFR-9.1 — which REQ-CHART-090 is blocked on — this issue's tests are the ones that must still pass afterwards. Write them so they will.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/spec-auditor.md` before the pull request
- **Required Human Review**: Architecture reviewer if any caching is introduced
- **Open Decisions**: `PQ-5` is recorded — if a self-assessed score does not count as the current score, AC-01's self-assessment clause changes accordingly. `PQ-8` and `PQ-10` (REQ-CHART-090's caching question) are recorded, since a cache introduced later must not break this.
- **Estimated effort**: 0.5–1 engineer-day; 200–400 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — mostly a thorough cross-surface test suite over behavior the upstream issues already provide, with no new mechanism to design.
