# [REQ-SCORE-030] Represent an unassessed skill as absent, never as a value

## Metadata

- **ID**: REQ-SCORE-030
- **Title**: Represent an unassessed skill as absent, never as a value
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Functional
- **Source / Parent**: REQ-SCORE-000; `REQUIREMENTS.md` FR-4.4, FR-7.9; `SECURITY.md` SEC-BIZ-4

## Requirement

- **Statement**: The system MUST distinguish a skill that has not been assessed for a team member from a skill scored 1, and an unassessed skill MUST NOT be defaulted to a numeric value anywhere in storage, the chart dataset or the score table.
- **Rationale**: FR-4.4 states the distinction and SEC-BIZ-4 names the three places it is most easily lost. `DESIGN.md`'s brand direction is explicit that nothing gamifies a low score — reporting "unassessed" as 1 would be the most consequential possible version of that mistake.
- **Assumptions**: None.
- **Out of Scope**: How the chart draws the gap (REQ-CHART-030) and how the table shows it (REQ-CHART-070) — those consume the absence marker this issue defines.
- **Design Traceability**: `DESIGN.md` — Charts (skills with no score for a member break the polygon at that axis and are marked in the legend rather than plotted as a value), Accessibility (Not colour alone — the absence must be conveyed textually too), Brand direction (nothing gamifies a low score).
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment — distinguishes unassessed from scored 1; Chart Data Service — explicit absence markers (FR-7.9); DR-7 (the chart and table read the same dataset, so the marker travels once).
- **Security Traceability**: SEC-BIZ-4, SEC-DATA-4, SEC-INPUT-2.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; Chart Data Service; Relational Data Store; REST API; Web Client
- **Interfaces / Operations**: Score read; chart dataset; score table; ranked list
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: REQ-SCORE-010 is Verified
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Integrity, Safety
- **Control Layers**: Business-Rule Validation, Data Protection
- **Threat References**: STRIDE — Tampering; CWE-1188 Initialization of a Resource with an Insecure Default
- **Abuse / Misuse Case**: An unassessed skill stored or serialized as 0 or 1 and read back as a real assessment, so a person is reported as having been measured and scored lowest when they were never assessed at all. The harm is to the individual described, not to the system.
- **Trust Boundary**: Assessment → REST API → clients — the marker must survive serialization at that boundary
- **Untrusted Inputs or Assertions**: N/A for this rule — the risk is internal defaulting, not hostile input
- **Authoritative Enforcement Point**: Assessment, which owns the representation; Chart Data Service, which must carry it through
- **Independent Verification**: A test asserting the absence marker survives from store to chart payload to table (SEC-BIZ-4)
- **Zero Trust Relevance**: N/A

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: CWE-1188 is cited because the failure mode here is precisely an insecure default value substituted for absence.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a member with a score of 1 for skill A and no assessment for skill B, when their scores are read through any surface, then skill A returns 1 and skill B returns an explicit absence marker distinguishable from 1 (FR-4.4).
2. **AC-02 — Boundary or failure behavior**: Given a chart dataset and its equivalent score table for that member, when both are produced from the same dataset, then skill B is marked absent in both and MUST NOT be plotted or tabulated as a number (FR-7.9, SEC-BIZ-4, DR-7).
3. **AC-03 — Prohibited behavior**: Given storage, the chart dataset or the score table, when any is inspected, then an unassessed skill MUST NOT appear as 0, 1, `null` coerced to a number, or any other numeric default (SEC-BIZ-4).

## Failure Behavior

- **On Invalid Input**: N/A — absence is a state, not an input
- **On Authentication Failure**: Refuse; return no score data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming the member exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default
- **On External Dependency Failure**: N/A
- **On System Error**: A dataset that cannot be assembled completely is an error, not a dataset with absences standing in for missing data — the two must not be conflated (SEC-ERR-2)
- **Logging / Audit**: N/A — absence is not an event
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: The absence representation at the Assessment boundary; serialization asserting it is not coerced to a number; the distinction between absent and 1 at every read
- **Integration Tests**: The marker asserted to survive from store to chart payload to table (SEC-BIZ-4); ranked lists asserting an unassessed member is not ordered as though scored
- **Security Tests**: A response-shape test per role confirming the absence marker is present rather than the field being omitted in a way a client might default (SEC-DATA-4)
- **Compliance Tests / Evidence**: WCAG 2.2 AA — the absence must be conveyed textually in the score table, not by an empty cell alone
- **Acceptance-Criteria Traceability**: AC-01 by the read test; AC-02 by the store-to-chart-to-table test; AC-03 by the storage and payload inspections
- **Coverage Target**: Every read surface covered for the absent case as well as the scored case
- **Required Test Environment**: The `UT-10.1` fixture, which includes at least one member with an unassessed skill

## Dependencies

- **Upstream Requirements**: REQ-SCORE-010
- **Downstream Requirements**: REQ-CHART-010, REQ-CHART-030, REQ-CHART-070, REQ-CHART-080, REQ-PORT-010
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: The representation must survive JSON serialization unambiguously — an omitted field is not the same as an explicit absence marker, and a client that defaults an omitted field would reintroduce exactly the bug this issue prevents.
- **Prohibited Approaches**: A sentinel numeric value such as 0 or -1; omitting the axis from the dataset, which would break FR-7.4's shared axis set; letting the client decide what a missing value means
- **Implementation Guidance**: Define the marker once, in the dataset contract, and carry it unchanged through REQ-CHART-010 to both the chart and the table — DR-7 means it only has to be right once.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/spec-auditor.md` before the pull request
- **Required Human Review**: Architecture reviewer for the dataset contract; product review of how absence is worded to the user
- **Open Decisions**: None
- **Estimated effort**: 0.5–1 engineer-day; 200–400 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a single representational rule, explicitly stated, with a clear end-to-end test; the care required is in coverage, not in reasoning.
