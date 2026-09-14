# [REQ-FOUND-020] Shared validation schemas applied server-side at the API boundary

## Metadata

- **ID**: REQ-FOUND-020
- **Title**: Shared validation schemas applied server-side at the API boundary
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Security
- **Source / Parent**: REQ-FOUND-000; `ARCHITECTURE.md` DR-1; `SECURITY.md` SEC-INPUT-1, SEC-INPUT-2; `CLAUDE.md` Workflow

## Requirement

- **Statement**: Validation schemas for every request payload MUST live in `shared/` and MUST be applied server-side at the API boundary; a client MAY reuse a schema only as a usability courtesy, and a client-side check MUST NOT be the only place a rule exists.
- **Rationale**: DR-1 states that no business rule may exist only in a client and that every validation is duplicated behind the API boundary. SEC-INPUT-1 requires validation for both shape and business meaning at the boundary where the payload enters, with rejection rather than coercion.
- **Assumptions**: None.
- **Out of Scope**: The score range rule's enforcement in Assessment (REQ-SCORE-020) and in the data store — this issue provides the schema, not the domain behavior. Bulk import's use of these schemas (REQ-PORT-020).
- **Design Traceability**: `DESIGN.md` — Components (Inputs: score entry accepts only integers 1–10 and states that range in helper text before the user errs) is the courtesy layer these schemas back.
- **Architecture Traceability**: `ARCHITECTURE.md` DR-1, DR-2; REST API as the sole enforcement point.
- **Security Traceability**: SEC-INPUT-1, SEC-INPUT-2, SEC-INPUT-3, SEC-BOUND-1, SEC-ERR-1.

## Scope

- **Applies To**: Multiple
- **Components**: `shared/`; REST API; Web Client; Mobile Client
- **Interfaces / Operations**: Every REST endpoint's request payload; the client form layer that reuses a schema for courtesy validation
- **Actors**: All roles; any caller reaching the API
- **Preconditions**: REQ-FOUND-010 is Verified
- **Data Classification**: Internal
- **Personal or Regulated Data**: None — the schemas describe shapes, not data
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Integrity, Authorization
- **Control Layers**: Input Validation, Architecture
- **Threat References**: STRIDE — Tampering; OWASP Top 10:2025 Injection
- **Abuse / Misuse Case**: A caller bypassing both clients and submitting a malformed, over-long, wrong-typed or extra-field payload directly to the API; a value coerced rather than rejected, so an out-of-range score becomes an in-range one.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Every request payload, whichever client it claims to come from
- **Authoritative Enforcement Point**: The REST API, applying the shared schema server-side
- **Independent Verification**: The server applies the schema regardless of whether the client did; API-level tests bypass both clients (SEC-BOUND-1)
- **Zero Trust Relevance**: N/A — this is input validation, and `REQUIREMENT_TEMPLATE.md` warns against using Zero Trust as a synonym for it

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: N/A
- **Mapping Basis**: No standard mapping has been verified; the governing rules are SEC-INPUT-1…3 and DR-1.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a well-formed payload for any endpoint, when it is submitted directly to the API with no client involved, then the shared schema validates it server-side and the request proceeds.
2. **AC-02 — Boundary or failure behavior**: Given a payload that is malformed, over-long, wrong-typed, or carries an extra field, when it is submitted, then the API rejects it, names the offending field, and MUST NOT coerce the value (SEC-INPUT-1).
3. **AC-03 — Prohibited behavior**: Given any validation rule stated in `REQUIREMENTS.md`, when the codebase is inspected, then that rule MUST NOT exist only in `web/` or `mobile/` (DR-1).

## Failure Behavior

- **On Invalid Input**: Reject with the field and a product-term reason; no state change (SEC-INPUT-1)
- **On Authentication Failure**: N/A — validation runs after authentication
- **On Authorization Failure**: N/A — handled by REQ-AUTH-060
- **On Security-Decision Failure**: Deny by default — an unrecognized payload shape is rejected, not accepted with unknown fields dropped silently
- **On External Dependency Failure**: N/A
- **On System Error**: No partial application of a rejected payload (SEC-ERR-2)
- **Logging / Audit**: Log the endpoint and the failing field name; MUST NOT log the payload values (SEC-LOG-3)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Each schema against valid, boundary and invalid values; explicit tests that an invalid value is rejected rather than coerced
- **Integration Tests**: Schema application asserted at the API boundary for each endpoint as endpoints are added
- **Security Tests**: Schema and boundary tests per endpoint with malformed, over-long, wrong-typed and extra fields (SEC-INPUT-1); a test that submits a rule-violating request directly to the API with both clients bypassed (SEC-BOUND-1)
- **Compliance Tests / Evidence**: N/A
- **Acceptance-Criteria Traceability**: AC-01 and AC-02 by the per-schema suite; AC-03 by a lint or review check that `web/` and `mobile/` import rules from `shared/` rather than redefining them
- **Coverage Target**: Every schema covers positive, boundary and negative cases
- **Required Test Environment**: None beyond the repository

## Dependencies

- **Upstream Requirements**: REQ-FOUND-010
- **Downstream Requirements**: REQ-SCORE-020, REQ-ROSTER-010, REQ-SKILL-010, REQ-CHART-020, REQ-PORT-020, and every other write path
- **External Dependencies**: A schema validation library, if one is added — justified in the pull request and checked against DEP-1…DEP-8 first
- **Dependency Assumptions**: Any library chosen rejects rather than coerces by default, or is configured to (SEC-INPUT-1)
- **Failure Impact**: Every write path depends on this; an unsound schema layer would weaken every endpoint at once.

## Implementation Notes

- **Constraints**: Schemas live in `shared/` and are applied server-side (`CLAUDE.md`); clients may reuse them only within DR-1's limits.
- **Prohibited Approaches**: Coercion of an invalid value; silently dropping unknown fields; a client-only rule
- **Implementation Guidance**: Keep the score schema here and the score *behavior* (supersession, history, audit) in REQ-SCORE-*; this issue owns shape and range, not domain effect.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review — this is input handling at a trust boundary
- **Open Decisions**: None
- **Estimated effort**: 1–2 engineer-days; 400–700 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — this is the single validation source every later write path reuses, and a subtle coercion or an over-permissive schema here weakens SEC-INPUT-1 across the whole API at once.
