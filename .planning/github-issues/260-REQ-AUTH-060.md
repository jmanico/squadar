# [REQ-AUTH-060] Role-based authorization enforcement at the API boundary

## Metadata

- **ID**: REQ-AUTH-060
- **Title**: Role-based authorization enforcement at the API boundary
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Security
- **Source / Parent**: REQ-AUTH-000; `REQUIREMENTS.md` FR-1.1, FR-1.6, FR-1.7; `SECURITY.md` SEC-AUTHZ-1, SEC-AUTHZ-2, SEC-AUTHZ-5, SEC-AUTHZ-7

## Requirement

- **Statement**: The REST API MUST verify, before performing any operation, that the authenticated actor is authorized for that operation on that specific target object, MUST deny by default when no rule explicitly permits the combination, MUST deny a Viewer every create, update and delete, and MUST report a refusal without disclosing the withheld data or confirming the existence of a record the actor may not see.
- **Rationale**: FR-1.7 states the refusal contract and `ARCHITECTURE.md` makes the REST API the sole enforcement point. SEC-AUTHZ-1's deny-by-default and SEC-AUTHZ-7's non-disclosure are what make the other role rules enforceable rather than advisory.
- **Assumptions**: FR-1.2's exactly-one-role model governs (`PQ-1` records the conflict with the ABAC language in the security notes); the decision function evaluates the documented attributes either way.
- **Out of Scope**: Context resolution (REQ-AUTH-050). The role-specific read and write rules that live with their domain — SEC-AUTHZ-3 in REQ-PORT-010 and REQ-CHART-010, SEC-AUTHZ-4 in REQ-SCORE-070, SEC-AUTHZ-6 in REQ-AUTH-070, SEC-AUTHZ-8 in REQ-EXAM-040 — all of which call the decision function this issue provides.
- **Design Traceability**: `DESIGN.md` — Form feedback and errors, for how a refusal is presented; Components (Buttons: disabled is never the only signal that an action is unavailable — say why in adjacent text).
- **Architecture Traceability**: `ARCHITECTURE.md` REST API — the single entry point and sole enforcement point for authorization and business rules; refuses impermissible requests without disclosing withheld data; DR-1, DR-2, DR-8.
- **Security Traceability**: SEC-AUTHZ-1, SEC-AUTHZ-2, SEC-AUTHZ-5, SEC-AUTHZ-7, SEC-AUTHN-1, SEC-BOUND-1, SEC-BOUND-2, SEC-ERR-1, SEC-DATA-4, SEC-HTTP-1, SEC-HTTP-2, SEC-LOG-2.

## Scope

- **Applies To**: API
- **Components**: REST API; Identity & Access (context source)
- **Interfaces / Operations**: Every protected read and state-changing operation across Roster, Skill Catalog, Assessment and Identity & Access
- **Actors**: Administrator, Assessor, Team Member, Viewer, unauthenticated caller
- **Preconditions**: The request carries a resolved authorization context (REQ-AUTH-050)
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Authorization, Confidentiality, Accountability
- **Control Layers**: Authorization, Architecture, Logging and Monitoring
- **Threat References**: STRIDE — Elevation of Privilege, Information Disclosure; OWASP Top 10:2025 Broken Access Control; CWE-862 Missing Authorization; CWE-639 Authorization Bypass Through User-Controlled Key; CWE-209 Generation of Error Message Containing Sensitive Information
- **Abuse / Misuse Case**: An endpoint added without an authorization check and reachable by any authenticated caller; an object identifier belonging to another team accepted because only the operation, not the target, was checked; a Viewer reaching a write path through import, export, exam submission or chart-configuration persistence; a denial message that reveals whether the named record exists.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: The requested operation, every target object identifier, and any attribute the caller supplies about themselves
- **Authoritative Enforcement Point**: The REST API — the sole enforcement point (DR-1, `ARCHITECTURE.md` REST API)
- **Independent Verification**: An automated authorization matrix over permitted and prohibited actor/object/operation combinations, including object identifiers belonging to another team (SEC-AUTHZ-1), plus a sweep of every state-changing endpoint with a Viewer actor (SEC-AUTHZ-5)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenets 4 and 6 — per-request, per-resource decisions on dynamic policy

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`; the applicable chapter is Authorization
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no control mapping verified against a specific catalog release
- **NIST SP 800-207**: §2.1 tenets 4 and 6
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: Both tenets are cited because SEC-AUTHZ-1 requires the decision to cover the specific target object and to be made before the operation, per request.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an authenticated actor and an operation their role permits on a target they are entitled to, when the request is made, then the decision function permits it and the operation proceeds.
2. **AC-02 — Boundary or failure behavior**: Given a Viewer, when every state-changing endpoint in the documented surface is called in turn, then each is denied — including any write path reachable through import, export, exam submission or chart-configuration persistence (FR-1.6, SEC-AUTHZ-5).
3. **AC-03 — Prohibited behavior**: Given a denial, when the response is compared between a target identifier that exists and one that does not, then the body, status code and observable behavior MUST NOT differ (FR-1.7, SEC-AUTHZ-7); and given an endpoint with no explicit permitting rule, the request MUST NOT be permitted (SEC-AUTHZ-1).

## Failure Behavior

- **On Invalid Input**: Reject at the boundary before the authorization decision is reached, with no state change (SEC-INPUT-1); reject a method or content type the route does not implement (SEC-HTTP-2)
- **On Authentication Failure**: Refuse; return no team member, score, exam, chart or account data (FR-1.1, SEC-AUTHN-1)
- **On Authorization Failure**: Deny; report the refusal without disclosing the withheld data or confirming the record exists (FR-1.7, SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: If the context cannot be resolved, fail closed rather than permitting (SEC-EXT-2)
- **On System Error**: No stack trace, query text, internal identifier, component name or dependency version in the response; diagnostics retained server-side under an opaque reference (SEC-ERR-1)
- **Logging / Audit**: Every authorization denial logged with actor, action, target and timestamp (SEC-LOG-2); the withheld data MUST NOT appear in the log line (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — depends on `PQ-10`

## Test Strategy

- **Unit Tests**: The decision function over the full actor × operation × target matrix, including the deny-by-default path for an unmapped combination
- **Integration Tests**: Each domain workstream's endpoints exercised through the decision function as they are added
- **Security Tests**: The automated authorization matrix including object identifiers belonging to another team (SEC-AUTHZ-1); the Viewer sweep over every state-changing endpoint (SEC-AUTHZ-5); denial-response comparison for existing vs. non-existing identifiers (SEC-AUTHZ-7); an unauthenticated sweep of the documented endpoint list asserting refusal and an empty body of product data (SEC-AUTHN-1); tests sending unexpected methods, content types and method-override headers (SEC-HTTP-2); a contract test asserting one documented endpoint set exercised identically with each client's user agent and build identifiers (SEC-BOUND-2); a plaintext-HTTP connection test (SEC-HTTP-1)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-01 and AC-02 by the authorization matrix and the Viewer sweep; AC-03 by the denial-comparison test and the deny-by-default case
- **Coverage Target**: Every endpoint × every role, positive and negative; no endpoint may be absent from the matrix
- **Required Test Environment**: The `UT-10.1` fixture with one account per role and cross-team object identifiers available

## Dependencies

- **Upstream Requirements**: REQ-AUTH-050
- **Downstream Requirements**: REQ-ROSTER-000, REQ-SKILL-000, REQ-SCORE-000, REQ-EXAM-000, REQ-CHART-000, REQ-PORT-000, REQ-AUTH-070 — every protected operation
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: The API is the sole enforcement point (DR-1); no endpoint may exist that serves one client and not the other, and the Mobile Client is not more trusted than the Web Client (DR-2, SEC-BOUND-2). Each response carries only the fields the caller's role and the screen require (SEC-DATA-4).
- **Prohibited Approaches**: Checking the operation without checking the target object; an allow-by-default route table; a denial that varies with the target's existence; filtering withheld data in a serializer or view layer instead of denying (DR-8)
- **Implementation Guidance**: Make the matrix test enumerate endpoints from the route table itself, so a new endpoint added without a rule fails the build rather than shipping unprotected — that is what turns SEC-AUTHZ-1's deny-by-default from a convention into a mechanism.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — authorization and trust boundary (`CLAUDE.md`)
- **Open Decisions**: `PQ-1` is recorded but does not block: the decision function evaluates the documented attributes under either reading. `PQ-6` (API error response format, `SQ-4`) affects the shape of the refusal payload but not its non-disclosure contract; record the format in `ARCHITECTURE.md` when chosen.
- **Estimated effort**: 1.5–2 engineer-days; 500–900 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — this is the single enforcement point for the whole product, and the required behavior is adversarial: deny by default, and make a denial reveal nothing.
