# [REQ-SKILL-030] Axis candidate list for chart configuration

## Metadata

- **ID**: REQ-SKILL-030
- **Title**: Axis candidate list for chart configuration
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-SKILL-000; `REQUIREMENTS.md` FR-7.5, FR-3.4; `ARCHITECTURE.md` Skill Catalog

## Requirement

- **Statement**: Skill Catalog MUST supply the list of skills a user may choose as a chart's axes, containing active skills only, so that the user can choose which skills from the catalog form the chart's axes.
- **Rationale**: FR-7.5 gives the user control of the axis set; `ARCHITECTURE.md` assigns supplying the candidates to Skill Catalog, which is also the component that knows which skills are retired (FR-3.4).
- **Assumptions**: FR-7.5 is marked **(assumed)** in `REQUIREMENTS.md` and stands.
- **Out of Scope**: The 3–12 axis limit, which is enforced on the selection by REQ-CHART-020, not on the candidate list. The selection control itself (REQ-CHART-040).
- **Design Traceability**: `DESIGN.md` — Components (Inputs: selection of skills for a chart uses checkable list items with a visible count of the current selection against its limit), Charts (one axis per selected skill, labelled at its vertex in Caption).
- **Architecture Traceability**: `ARCHITECTURE.md` Skill Catalog — supplies the axis candidates for chart configuration (FR-7.5); outputs active/retired status and axis candidate lists; DR-3, DR-4.
- **Security Traceability**: SEC-AUTHZ-1, SEC-INPUT-6, SEC-HTTP-6, SEC-BIZ-3, SEC-RENDER-1.

## Scope

- **Applies To**: API
- **Components**: Skill Catalog; Chart Data Service; REST API; Web Client
- **Interfaces / Operations**: Axis candidate list read
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: REQ-SKILL-010 and REQ-SKILL-020 are Verified
- **Data Classification**: Internal
- **Personal or Regulated Data**: None
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Integrity, Availability
- **Control Layers**: Input Validation, Availability, Output Encoding
- **Threat References**: STRIDE — Tampering, Denial of Service; OWASP Top 10:2025 Injection
- **Abuse / Misuse Case**: An unbounded candidate list requested at the NFR-9.3 scale of 100 skills and used as an amplification vector; an injection payload in a sort or filter parameter; a retired skill offered as a candidate and then rejected at assessment time, which would be a confusing failure rather than a prevented one.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Sort, filter and pagination parameters on the candidate list
- **Authoritative Enforcement Point**: Skill Catalog behind the REST API
- **Independent Verification**: Sortable and filterable fields come from a server-side allow-list, not from the request (SEC-INPUT-6)
- **Zero Trust Relevance**: N/A — the catalog is readable by every authenticated role

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: N/A
- **Mapping Basis**: No standard mapping is verified; the governing rules are FR-7.5, SEC-INPUT-6 and SEC-HTTP-6.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a catalog containing active and retired skills, when the axis candidate list is requested, then it contains every active skill and no retired one (FR-7.5, FR-3.4).
2. **AC-02 — Boundary or failure behavior**: Given a catalog at the NFR-9.3 scale of 100 skills, when the candidate list is requested without pagination parameters, then the response is bounded by the documented page size rather than returning the whole catalog unbounded (SEC-HTTP-6).
3. **AC-03 — Prohibited behavior**: Given a sort or filter parameter naming a field that is not on the server-side allow-list, when it is submitted, then it MUST NOT be interpolated into the query and the request is rejected (SEC-INPUT-6).

## Failure Behavior

- **On Invalid Input**: Reject an out-of-allow-list sort or filter parameter with the reason named; return no list (SEC-INPUT-1, SEC-INPUT-6)
- **On Authentication Failure**: Refuse; return no catalog data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny (SEC-AUTHZ-1)
- **On Security-Decision Failure**: Deny by default
- **On External Dependency Failure**: N/A
- **On System Error**: Return an error with no internal detail; return no partial list (SEC-ERR-1)
- **Logging / Audit**: N/A — catalog reads are not security events
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: The active-only filter; the sort and filter allow-list; page-size bounding
- **Integration Tests**: The candidate list consumed by the chart selection control, asserting a retired skill never reaches it
- **Security Tests**: Injection payloads in sort, filter and pagination parameters (SEC-INPUT-6); an unbounded-request test asserting the documented bound (SEC-HTTP-6); markup payloads in a skill name asserted to render literally in the candidate list (SEC-RENDER-1)
- **Compliance Tests / Evidence**: N/A
- **Acceptance-Criteria Traceability**: AC-01 by the active-only test; AC-02 by the 100-skill bounding test; AC-03 by the allow-list tests
- **Coverage Target**: Positive and negative coverage on the filter, the allow-list and the bound
- **Required Test Environment**: The `UT-10.1` fixture plus a 100-skill scale fixture for AC-02

## Dependencies

- **Upstream Requirements**: REQ-SKILL-010, REQ-SKILL-020
- **Downstream Requirements**: REQ-CHART-020, REQ-CHART-040
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: The candidate list is a read from Skill Catalog; Chart Data Service reads it rather than querying skill tables itself (DR-4).
- **Prohibited Approaches**: Filtering retired skills in the client; concatenating a sort or filter value into query text; an unbounded list at NFR-9.3 scale
- **Implementation Guidance**: Keeping the active-only filter here rather than in the chart layer means a retired skill can never be offered as an axis in the first place, which is a prevention rather than a rejection.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/spec-auditor.md` before the pull request
- **Required Human Review**: Security reviewer for the sort and filter allow-list
- **Open Decisions**: `PQ-6` is recorded — the pagination convention is `TO BE DECIDED` in `ARCHITECTURE.md`; this issue must bound the list, and should adopt the project convention once it exists rather than inventing a second one.
- **Estimated effort**: 0.5 engineer-day; 150–300 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a single bounded read with a filter and an allow-list, all stated.
