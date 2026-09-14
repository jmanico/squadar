# [REQ-PORT-030] Administrator interface for creating team members and skills

## Metadata

- **ID**: REQ-PORT-030
- **Title**: Administrator interface for creating team members and skills
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-PORT-000; `REQUIREMENTS.md` FR-8.1, FR-2.2, FR-3.2; `DESIGN.md` Components

## Requirement

- **Statement**: An Administrator MUST be able to create team members and skills through the user interface, using forms that meet the design language's input, feedback and accessibility rules, with every rule enforced server-side and the client's validation acting only as a courtesy layer.
- **Rationale**: FR-8.1 requires interactive creation, and it is the path SEC-INPUT-4 measures the import path against — so this surface defines what "the same server-side rules" means in practice.
- **Assumptions**: FR-8.1 is marked **(assumed)** in `REQUIREMENTS.md` and stands.
- **Out of Scope**: The server-side behavior itself (REQ-ROSTER-020, REQ-SKILL-010); bulk import (REQ-PORT-020, blocked); account creation, which is Identity & Access and REQ-AUTH-070.
- **Design Traceability**: `DESIGN.md` — Components (Inputs: persistent visible label above each field, never a placeholder as the label; 1 px `border` on `surface`, rounded 4 px, 16 px text so mobile browsers do not zoom on focus; helper text below in Small/`text-muted`; required fields marked in the label, not by colour alone. Buttons: one primary action per view), Form feedback and errors (validate on submit, and on blur only for a field already completed; three simultaneous error signals; focus to the first invalid field; a summary listing every error with links), Layout and Spacing (forms are comfortable, 16–24 px internal padding), Accessibility (full keyboard operability). `style-guide.html` is the rendered reference.
- **Architecture Traceability**: `ARCHITECTURE.md` Web Client — renders all screens for the four roles and presents client-side validation as a courtesy layer only; Roster and Skill Catalog apply the change under their own rules; DR-1, DR-2, DR-3.
- **Security Traceability**: SEC-INPUT-1, SEC-BOUND-1, SEC-AUTHZ-5, SEC-AUTHZ-6, SEC-RENDER-1, SEC-ERR-1.

## Scope

- **Applies To**: Web Client
- **Components**: Web Client; Roster; Skill Catalog; REST API
- **Interfaces / Operations**: The member creation form; the skill creation form
- **Actors**: Administrator — including keyboard-only and assistive-technology users
- **Preconditions**: REQ-ROSTER-020, REQ-SKILL-010, REQ-UIKIT-030 and REQ-UIKIT-050 are Verified
- **Data Classification**: Confidential
- **Personal or Regulated Data**: Personal Data — the member form collects data about an identifiable individual
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Integrity, Authorization
- **Control Layers**: Input Validation, Authorization, Output Encoding
- **Threat References**: STRIDE — Tampering, Elevation of Privilege; OWASP Top 10:2025 Injection; CWE-602 Client-Side Enforcement of Server-Side Security; CWE-79 Improper Neutralization of Input During Web Page Generation
- **Abuse / Misuse Case**: A validation rule implemented only in this form, so a direct API call bypasses it; a non-Administrator reaching the form's endpoints; a name containing markup echoed back into the confirmation or the list and rendered as HTML.
- **Trust Boundary**: Clients → REST API
- **Untrusted Inputs or Assertions**: Every field value submitted, and every value echoed back into the page
- **Authoritative Enforcement Point**: Roster and Skill Catalog behind the REST API; this form duplicates their rules as a courtesy only (DR-1)
- **Independent Verification**: The same rule tested at the API with the client bypassed (SEC-BOUND-1)
- **Zero Trust Relevance**: N/A — the client makes no access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: W3C WCAG 2.2 Level AA — 3.3.1 Error Identification, 3.3.2 Labels or Instructions, 3.3.3 Error Suggestion, 2.1.1 Keyboard, 1.4.1 Use of Color
- **Mapping Basis**: `DESIGN.md` states a persistent visible label, required marking that is not colour alone, an error naming what is wrong and what to do, and full keyboard operability — each maps to one criterion named.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an Administrator, when they submit the member form or the skill form with valid values, then the record is created through the owning component and the success is confirmed in text that persists until they move on (FR-8.1, FR-2.2, FR-3.2).
2. **AC-02 — Boundary or failure behavior**: Given a skill name duplicating an existing active skill, when the form is submitted, then the server's rejection is presented through the standard error contract — border, symbol, message naming what is wrong and what to do, focus to the field, and a summary entry linking to it (FR-3.3, `DESIGN.md` Form feedback and errors).
3. **AC-03 — Prohibited behavior**: Given any validation rule this form applies, when the same value is submitted directly to the API with the client bypassed, then it MUST still be rejected — the rule MUST NOT exist only here (DR-1, SEC-BOUND-1); and a submitted name containing markup MUST NOT be rendered as markup when echoed back (SEC-RENDER-1).

## Failure Behavior

- **On Invalid Input**: The standard error contract from REQ-UIKIT-050; no record created (SEC-INPUT-1)
- **On Authentication Failure**: The form is not reachable; the server returns no data (SEC-AUTHN-1)
- **On Authorization Failure**: A non-Administrator's submission is denied server-side; the refusal is presented without confirming whether the named record exists (SEC-AUTHZ-6, SEC-AUTHZ-7)
- **On Security-Decision Failure**: N/A — the client makes no security decision (DR-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Present the server's product-term message; leave the entered values in place so the work is not lost (SEC-ERR-1)
- **Logging / Audit**: The creation is logged by the owning component with actor, action, target and timestamp (SEC-LOG-2)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Form state and field validation reusing the `shared/` schemas; error presentation per field; success confirmation persistence
- **Integration Tests**: Member and skill creation round trips through the REST API; a server-side rejection rendered through the error contract
- **Security Tests**: The same values submitted directly to the API with the client bypassed, asserting identical rejection (SEC-BOUND-1, DR-1); a non-Administrator submission asserting denial (SEC-AUTHZ-6); a Viewer sweep (SEC-AUTHZ-5); markup payloads in every field asserted to render literally when echoed (SEC-RENDER-1)
- **Compliance Tests / Evidence**: WCAG 2.2 AA — persistent visible labels, required marking not by colour, keyboard-only completion of both forms, error announcement, and layout at each breakpoint
- **Acceptance-Criteria Traceability**: AC-01 by the creation round trips; AC-02 by the duplicate-name rendering test; AC-03 by the direct-API parity test and the echo test
- **Coverage Target**: Every field on both forms, valid and invalid, by pointer and by keyboard, in both modes
- **Required Test Environment**: The `UT-10.1` fixture as pre-existing state for the uniqueness case; a keyboard-only profile

## Dependencies

- **Upstream Requirements**: REQ-ROSTER-020, REQ-SKILL-010, REQ-UIKIT-030, REQ-UIKIT-040, REQ-UIKIT-050, REQ-FOUND-020
- **Downstream Requirements**: REQ-PORT-020 — SEC-INPUT-4 requires the import path to produce the same rejection reasons this path produces
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: `DESIGN.md` specifies one primary action per view, a persistent visible label above every input, and 16 px input text. Client validation is a courtesy layer duplicated behind the API boundary (DR-1).
- **Prohibited Approaches**: A placeholder as the label; required fields marked by colour alone; a validation rule implemented only in this form; echoing a submitted value as raw HTML
- **Implementation Guidance**: Reuse the `shared/` schemas from REQ-FOUND-020 for the courtesy validation. That is what makes the interactive path and the import path give the same reasons, which is what SEC-INPUT-4 will be measured against when REQ-PORT-020 unblocks.
- **AI Development Guidance**: `CLAUDE.md`; read `DESIGN.md` and `style-guide.html` together
- **Required Human Review**: Accessibility reviewer for both forms
- **Open Decisions**: None
- **Estimated effort**: 1–1.5 engineer-days; 350–600 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — two forms built from existing primitives against an explicitly stated interaction contract, with the server-side rules already delivered elsewhere.
