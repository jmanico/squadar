# [REQ-FOUND-030] Synthetic ten-member, ten-skill test fixture

## Metadata

- **ID**: REQ-FOUND-030
- **Title**: Synthetic ten-member, ten-skill test fixture
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Operational
- **Source / Parent**: REQ-FOUND-000; `REQUIREMENTS.md` UT-10.1; `SECURITY.md` SEC-DATA-5

## Requirement

- **Statement**: The repository MUST provide a fixture of ten synthetic team members with ten different skill levels, usable by every build step, and it MUST NOT reproduce any real person's identity or scores.
- **Rationale**: UT-10.1 requires exactly this so the whole system can be tested repeatedly at each build step. `CLAUDE.md` makes keeping the fixture usable by every build step a standing rule, and SEC-DATA-5 governs what may be in it.
- **Assumptions**: "10 different skills levels" means the fixture covers the 1–10 range, so chart, table and ranking behavior can be exercised across the full scale.
- **Out of Scope**: Seeding a deployed environment; any production data path.
- **Design Traceability**: N/A — the fixture ships no user-facing surface, though it is what lets chart and table surfaces be rendered in test.
- **Architecture Traceability**: `ARCHITECTURE.md` Roster, Skill Catalog and Assessment own the objects the fixture creates; the fixture writes through their interfaces rather than into storage directly (DR-3, DR-4).
- **Security Traceability**: SEC-DATA-5, SEC-DATA-1, SEC-SECRET-1.

## Scope

- **Applies To**: Multiple
- **Components**: Roster; Skill Catalog; Assessment; the test harness
- **Interfaces / Operations**: Fixture generation and reset between test runs
- **Actors**: Developers; the CI pipeline
- **Preconditions**: REQ-FOUND-010 is Verified
- **Data Classification**: Internal
- **Personal or Regulated Data**: None — the fixture is synthetic by requirement
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Privacy, Confidentiality
- **Control Layers**: Data Protection
- **Threat References**: STRIDE — Information Disclosure; OWASP Top 10:2025 Security Misconfiguration
- **Abuse / Misuse Case**: Personal performance data copied from production into a fixture, a seed or a demo environment, where it is exposed to everyone with repository access.
- **Trust Boundary**: Production data store → non-production environments; the fixture must never carry data across it
- **Untrusted Inputs or Assertions**: N/A — the fixture's content is authored, not received
- **Authoritative Enforcement Point**: A CI check that seed data is generated rather than imported from a production source (SEC-DATA-5)
- **Independent Verification**: The CI check runs regardless of the author's assertion that the data is synthetic
- **Zero Trust Relevance**: N/A

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13`; if GDPR or CCPA apply, non-production use of personal data is directly in scope
- **Other**: N/A
- **Mapping Basis**: Regulatory scope is TO BE DECIDED rather than N/A because `SQ-1` leaves applicability open and this issue is precisely where a breach of it would occur.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a clean test database, when the fixture is applied, then ten team members and ten skills exist, the recorded scores span the 1–10 range, at least one member has an unassessed skill, at least one member is deactivated, and at least one skill is retired.
2. **AC-02 — Boundary or failure behavior**: Given a test run that has mutated fixture data, when the fixture is reset, then the next test run starts from the identical state — the fixture is reproducible, not accumulative.
3. **AC-03 — Prohibited behavior**: Given the fixture source, when the CI check runs, then it MUST NOT be derived from, or contain values imported from, a production source, and MUST NOT reproduce a real person's identity or scores (SEC-DATA-5).

## Failure Behavior

- **On Invalid Input**: A fixture that fails the domain components' own validation fails the test run loudly rather than being written through a back door
- **On Authentication Failure**: N/A
- **On Authorization Failure**: N/A
- **On Security-Decision Failure**: N/A
- **On External Dependency Failure**: N/A
- **On System Error**: A partially applied fixture fails the run rather than leaving tests to pass against incomplete data
- **Logging / Audit**: N/A
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Fixture generation is deterministic — the same input yields the same members, skills and scores
- **Integration Tests**: The fixture applied through Roster, Skill Catalog and Assessment interfaces, asserting it satisfies each component's own rules
- **Security Tests**: The CI check that seed data is generated, not imported (SEC-DATA-5); a review item on the fixture contents
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by a fixture-shape assertion; AC-02 by a reset-and-compare test; AC-03 by the CI provenance check
- **Coverage Target**: The fixture itself is test infrastructure; the target is that every later issue's test environment is satisfiable from it
- **Required Test Environment**: A disposable test database

## Dependencies

- **Upstream Requirements**: REQ-FOUND-010
- **Downstream Requirements**: Every issue whose Test Strategy names the `UT-10.1` fixture — which is nearly all of them
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: The fixture must stay usable by every build step (`CLAUDE.md`), so it grows with the domain rather than being frozen at first write.
- **Prohibited Approaches**: Copying production data; writing fixture rows straight into storage, bypassing the owning components' rules (DR-4)
- **Implementation Guidance**: Include the awkward cases deliberately — an unassessed skill, a deactivated member, a retired skill — because FR-4.4, FR-2.3 and FR-3.4 are the rules most easily lost, and a fixture without them lets a regression pass.
- **AI Development Guidance**: `CLAUDE.md`
- **Required Human Review**: Security review of the fixture contents against SEC-DATA-5
- **Open Decisions**: None
- **Estimated effort**: 0.5–1 engineer-day; 150–350 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — mechanical, fully specified data construction against a stated shape, with the only judgement call being which edge cases to include, and those are named above.
