# [REQ-ROSTER-010] Team member record with distinct identity

## Metadata

- **ID**: REQ-ROSTER-010
- **Title**: Team member record with distinct identity
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Functional
- **Source / Parent**: REQ-ROSTER-000; `REQUIREMENTS.md` FR-2.1; `ARCHITECTURE.md` Roster

## Requirement

- **Statement**: The system MUST maintain a record of each team member who can be assessed, identified distinctly from all other team members, and Roster MUST be the only component that mutates it.
- **Rationale**: FR-2.1 requires a distinct identity per member. Every score, chart series, authorization decision and audit entry refers to a member by that identity, so it must be established before any of them.
- **Assumptions**: A team member and a user account are distinct objects — `ARCHITECTURE.md` has Identity & Access read Roster to link a user to a team member, which implies they are not the same record.
- **Out of Scope**: The member lifecycle — add, edit, deactivate — which REQ-ROSTER-020 owns. Teams (REQ-ROSTER-030). Deletion (REQ-ROSTER-050, blocked).
- **Design Traceability**: `DESIGN.md` — Components (Inputs: persistent visible label, required fields marked in the label not by colour).
- **Architecture Traceability**: `ARCHITECTURE.md` Roster — owns team members, teams and team membership; Assessment references members by identity and never mutates them; DR-3, DR-4.
- **Security Traceability**: SEC-AUTHZ-1, SEC-AUTHZ-2, SEC-INPUT-1, SEC-DATA-4, SEC-RENDER-1.

## Scope

- **Applies To**: Server-Side Application
- **Components**: Roster; Relational Data Store; REST API
- **Interfaces / Operations**: Member record shape; member read by identity; member list
- **Actors**: Administrator, Assessor, Team Member, Viewer
- **Preconditions**: REQ-FOUND-020 and REQ-AUTH-060 are Verified
- **Data Classification**: Confidential
- **Personal or Regulated Data**: Personal Data — a member record names an identifiable individual
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Integrity, Confidentiality
- **Control Layers**: Input Validation, Authorization, Data Protection
- **Threat References**: STRIDE — Tampering, Information Disclosure; OWASP Top 10:2025 Broken Access Control; CWE-639 Authorization Bypass Through User-Controlled Key
- **Abuse / Misuse Case**: A member identifier that is guessable and used to enumerate records; two members indistinguishable because identity rests on a mutable display name; a member record over-returned with fields the caller's role does not require.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Member identifiers supplied in a request, and every free-text field on the record
- **Authoritative Enforcement Point**: Roster, behind the REST API
- **Independent Verification**: Distinctness is enforced by the Relational Data Store, not only by application logic
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — access to a member record is evaluated per request against the requester's relationship to it

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: Tenet 4 applies because FR-1.4 and FR-1.5 make member access depend on the requester's linkage and team assignment.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given two team members with identical display names, when both are stored, then each is retrievable distinctly by its own identity and neither shadows the other (FR-2.1).
2. **AC-02 — Boundary or failure behavior**: Given a request naming a member identifier that does not exist, when it is made by an actor who would not be entitled to that member anyway, then the response is indistinguishable from the response for a member that exists but is withheld (SEC-AUTHZ-7).
3. **AC-03 — Prohibited behavior**: Given any component other than Roster, when it handles a member record, then it MUST NOT mutate it — it references the member by identity and requests changes through Roster (DR-3).

## Failure Behavior

- **On Invalid Input**: Reject with the field and reason named; no record created (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; return no member data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the named member exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; no partially created member record (SEC-ERR-2)
- **Logging / Audit**: Member reads are not audited; member mutations are logged with actor, action, target and timestamp by REQ-ROSTER-020 (SEC-LOG-2). Member names MUST NOT appear in general application logs (SEC-LOG-3)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Identity generation and uniqueness; record shape validation; retrieval by identity
- **Integration Tests**: Distinctness enforced at the data store under concurrent creation of identically named members; a reference held by Assessment resolving to the correct member
- **Security Tests**: Denial-response comparison for existing vs. non-existing member identifiers (SEC-AUTHZ-7); a response-shape test per role against the documented per-role field list (SEC-DATA-4); markup payloads in a member name asserted to render literally (SEC-RENDER-1)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 by the duplicate-name distinctness test; AC-02 by the denial-comparison test; AC-03 by a review and a module-boundary check that no component outside Roster writes member records
- **Coverage Target**: Positive and negative coverage on identity, retrieval and authorization
- **Required Test Environment**: The `UT-10.1` fixture — ten synthetic members, including two with the same display name

## Dependencies

- **Upstream Requirements**: REQ-FOUND-020, REQ-AUTH-060
- **Downstream Requirements**: REQ-ROSTER-020, REQ-ROSTER-030, REQ-ROSTER-040, REQ-SCORE-010, REQ-AUTH-050, REQ-CHART-010
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: Third normal form per `ARCHITECTURE.md`'s data model expectations. The database product is `TO BE DECIDED` (`PQ-8`), so this issue defines the record and its constraints in terms the eventual schema must satisfy rather than presuming a product.
- **Prohibited Approaches**: Identity resting on a mutable display name or email; a sequential identifier used as the externally exposed key where it enables enumeration; another component writing member rows directly (DR-4)
- **Implementation Guidance**: Keep the member record minimal here — lifecycle status belongs to REQ-ROSTER-020 and membership to REQ-ROSTER-030, so each rule has one owner.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/spec-auditor.md` before the pull request
- **Required Human Review**: Architecture reviewer for the identity model
- **Open Decisions**: `PQ-8` (database product and schema shape) is recorded; it does not block defining the record and its constraints, but the concrete schema lands with the product choice.
- **Estimated effort**: 0.5–1 engineer-day; 250–450 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a single, well-specified record with one constraint, sitting behind an authorization layer that already exists.
