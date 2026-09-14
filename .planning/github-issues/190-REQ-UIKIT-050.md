# [REQ-UIKIT-050] Form feedback, error messaging and error summary

## Metadata

- **ID**: REQ-UIKIT-050
- **Title**: Form feedback, error messaging and error summary
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-UIKIT-000; `DESIGN.md` Form feedback and errors; `SECURITY.md` SEC-ERR-1

## Requirement

- **Statement**: Forms MUST validate on submit, and on blur only for a field the user has already completed; an error MUST show the field border in `error`, an icon or symbol beside the message, and message text naming what is wrong and what to do, programmatically tied to its input; on submit failure focus MUST move to the first invalid field and a summary MUST list every error with links to the fields; and success MUST be confirmed in text and persist until the user moves on.
- **Rationale**: `DESIGN.md` states this contract precisely, including that an error shows three things at once and that success is not signalled by colour alone or dismissed on a timer. SEC-ERR-1 sets what a message may and may not contain.
- **Assumptions**: None.
- **Out of Scope**: Server-side validation itself (REQ-FOUND-020); the import per-row rejection report, which REQ-PORT-020 builds on this pattern.
- **Design Traceability**: `DESIGN.md` — Components (Form feedback and errors, in full; Inputs: helper text and required marking), Color Palette (`error` and `success` are used only for form feedback and system state — never to characterize a person's score), Accessibility (Not colour alone).
- **Architecture Traceability**: `ARCHITECTURE.md` Web Client — client-side validation is a courtesy layer only, always duplicated behind the API boundary (DR-1).
- **Security Traceability**: SEC-ERR-1, SEC-AUTHN-6, SEC-AUTHZ-7, SEC-RENDER-1.

## Scope

- **Applies To**: Web Client
- **Components**: Web Client
- **Interfaces / Operations**: Every form in the product — sign-in, member and skill entry, score entry, exam submission, import
- **Actors**: All four roles, including keyboard-only and assistive-technology users
- **Preconditions**: REQ-UIKIT-030 and REQ-UIKIT-040 are Verified
- **Data Classification**: Internal — messages may echo submitted field names
- **Personal or Regulated Data**: None — messages name fields and rules, not personal values
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Confidentiality, Safety
- **Control Layers**: Output Encoding, Other
- **Threat References**: STRIDE — Information Disclosure; OWASP Top 10:2025 Security Misconfiguration
- **Abuse / Misuse Case**: An error message echoing a stack trace, query text, internal identifier or component name from the server; a sign-in error that reveals whether the account exists; a denial message that confirms a hidden record exists.
- **Trust Boundary**: REST API → Web Client — the server's error payload is rendered, not interpreted
- **Untrusted Inputs or Assertions**: Server-supplied error messages and import row reasons, which are rendered as text
- **Authoritative Enforcement Point**: The server decides what a message may say (SEC-ERR-1, SEC-AUTHN-6, SEC-AUTHZ-7); this issue renders it without adding detail
- **Independent Verification**: A fault-injection test asserting responses carry no internal detail, run against the API rather than the client (SEC-ERR-1)
- **Zero Trust Relevance**: N/A

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: N/A
- **Other**: W3C WCAG 2.2 Level AA — 3.3.1 Error Identification, 3.3.3 Error Suggestion, 1.4.1 Use of Color, 4.1.3 Status Messages
- **Mapping Basis**: `DESIGN.md` requires the error to name what is wrong (3.3.1) and what to do (3.3.3), to show a symbol as well as colour (1.4.1), and to confirm success in text that persists (4.1.3).

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given a form with an invalid score field, when it is submitted, then the field border is `error`, an icon or symbol sits beside the message, the message reads in the form "Score must be a whole number from 1 to 10", the message is programmatically associated with its input, focus moves to that field, and a summary above lists every error with a link to each field.
2. **AC-02 — Boundary or failure behavior**: Given a user typing in a field they have not yet completed, when the first keystroke is entered, then no error is shown — validation runs on submit, and on blur only for a field already completed.
3. **AC-03 — Prohibited behavior**: Given any error rendered by this layer, when it is inspected, then it MUST NOT contain a stack trace, query text, internal identifier, component name or dependency version (SEC-ERR-1); and success MUST NOT be signalled by colour alone, nor dismissed on a timer.

## Failure Behavior

- **On Invalid Input**: The contract above — three simultaneous signals, focus to the first invalid field, a linked summary
- **On Authentication Failure**: Render the server's uniform message; the client MUST NOT distinguish unknown account from wrong credential (SEC-AUTHN-6)
- **On Authorization Failure**: Render the refusal without implying whether the target exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Show the refusal; never fall through to a success state
- **On External Dependency Failure**: N/A
- **On System Error**: Render the server's product-term message and its opaque reference, so a user can quote it to support without it disclosing anything (SEC-ERR-1)
- **Logging / Audit**: N/A — the client logs no security event
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Error association with its input; summary construction and link targets; focus movement to the first invalid field; validate-on-blur gating by completion; success persistence
- **Integration Tests**: A form round trip against a server rejection, asserting the rendered contract
- **Security Tests**: Fault-injection against the API asserting no internal detail reaches the message (SEC-ERR-1); a comparison test that sign-in errors are identical for existing and non-existing identifiers as rendered (SEC-AUTHN-6); markup payloads in a server-supplied error message asserted to display literally (SEC-RENDER-1)
- **Compliance Tests / Evidence**: Automated checks for 3.3.1, 3.3.3, 1.4.1 and 4.1.3; a screen-reader pass confirming the summary and each message are announced
- **Acceptance-Criteria Traceability**: AC-01 by the error-contract test; AC-02 by the keystroke and blur tests; AC-03 by the fault-injection test and the success-state test
- **Coverage Target**: Every error path in every form primitive, positive and negative
- **Required Test Environment**: A server or stub that can return each error class; a screen reader for the manual pass

## Dependencies

- **Upstream Requirements**: REQ-UIKIT-030, REQ-UIKIT-040
- **Downstream Requirements**: REQ-PORT-020, REQ-PORT-030, REQ-AUTH-010, REQ-SCORE-020, REQ-EXAM-050
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: `error` and `success` are for form feedback and system state only — `DESIGN.md` forbids using them to characterize a person's score.
- **Prohibited Approaches**: Validating on first keystroke; a toast that vanishes on a timer as the only success confirmation; colour as the sole error or success signal; the client inventing detail the server did not send
- **Implementation Guidance**: The message wording in `DESIGN.md` — "Score must be a whole number from 1 to 10" — is a worked example of the required form: what is wrong and what to do. Match it rather than paraphrasing.
- **AI Development Guidance**: `CLAUDE.md`; read `DESIGN.md` and `style-guide.html` together
- **Required Human Review**: Accessibility reviewer; security reviewer for the error-content contract
- **Open Decisions**: None
- **Estimated effort**: 1–1.5 engineer-days; 350–600 changed human-authored lines
- **Recommended model**: Claude Sonnet 5 (`claude-sonnet-5`) — a precisely stated interaction contract; the security-sensitive part is refraining from adding detail, which the fault-injection test verifies.
