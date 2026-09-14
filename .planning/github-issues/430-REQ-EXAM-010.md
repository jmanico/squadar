# [REQ-EXAM-010] Define an exam for a single skill with its questions and answer key

## Metadata

- **ID**: REQ-EXAM-010
- **Title**: Define an exam for a single skill with its questions and answer key
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Functional
- **Source / Parent**: REQ-EXAM-000; `REQUIREMENTS.md` FR-5.4; `SECURITY.md` SEC-AUTHZ-6, SEC-BOUND-3

## Requirement

- **Statement**: An Administrator MUST be able to define an exam, specifying the single skill it measures and its questions with their correct answers, and the answer key MUST be stored such that no read path serving a Team Member or Viewer can reach it.
- **Rationale**: FR-5.4 fixes the exam's shape — one skill, questions, correct answers. NFR-9.7 makes the key confidential absolutely, and the cheapest way to honour that is to store it so that the exam-delivery query structurally cannot select it.
- **Assumptions**: One exam measures exactly one skill (FR-5.4, stated). An exam has at least one question; a zero-question exam would make FR-5.7's percentage undefined.
- **Out of Scope**: Assignment (REQ-EXAM-020); delivery to an assignee (REQ-EXAM-030); scoring (REQ-EXAM-050); exam media (REQ-EXAM-070, blocked on `PQ-16`); per-question weights and pass thresholds (`OQ-2`, recorded).
- **Design Traceability**: `DESIGN.md` — Layout and Spacing (long-form text, including exam questions, caps at 72 characters per line), Components (Inputs, Form feedback and errors).
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment — owns exam definitions and answer keys; answer keys never leave this component toward a Team Member or Viewer; DR-3, DR-8.
- **Security Traceability**: SEC-AUTHZ-6, SEC-BOUND-3, SEC-DATA-4, SEC-INPUT-1, SEC-RENDER-1, SEC-LOG-3, SEC-ERR-2.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; Relational Data Store; REST API; Web Client
- **Interfaces / Operations**: Exam create, edit and read (Administrator view, including the key); exam list
- **Actors**: Administrator (write and full read); Assessor (read without key, for assignment); Team Member and Viewer (no access to the definition)
- **Preconditions**: REQ-SKILL-010 is Verified and the exam's skill is active (FR-3.4)
- **Data Classification**: Restricted — the answer key is the most sensitive non-credential data in the system
- **Personal or Regulated Data**: None — an exam definition describes content, not a person
- **Jurisdiction / Regulatory Scope**: N/A

## Security Context

- **Security Objectives**: Confidentiality, Integrity, Authorization
- **Control Layers**: Authorization, Data Protection, Architecture
- **Threat References**: STRIDE — Information Disclosure, Elevation of Privilege; OWASP Top 10:2025 Broken Access Control; CWE-200 Exposure of Sensitive Information to an Unauthorized Actor; CWE-213 Exposure of Sensitive Information Due to Incompatible Policies
- **Abuse / Misuse Case**: A Team Member or Viewer reading the exam definition and obtaining the answer key; a non-Administrator creating or editing an exam, including altering the key of an exam already assigned; the key appearing in an error response, a debug field or a log line.
- **Trust Boundary**: Clients → REST API → Assessment
- **Untrusted Inputs or Assertions**: Exam identifiers, question and answer text, and the skill reference
- **Authoritative Enforcement Point**: Assessment — the key is excluded inside the owning component before a response is assembled, never filtered in a serializer, view layer or client (SEC-BOUND-3, DR-8)
- **Independent Verification**: A test asserting that every exam-facing response shape reaching a Team Member or Viewer omits answer-key fields, including error and debug paths (SEC-BOUND-3)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 4 — access to the definition is decided per request by role

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A — exam content is authored, not model-generated
- **NIST SP 800-53 Rev. 5**: N/A — no control mapping verified against a specific catalog release
- **NIST SP 800-207**: §2.1 tenet 4
- **Regulatory**: N/A
- **Other**: N/A
- **Mapping Basis**: CWE-200 is cited because the single failure this issue exists to prevent is exposure of the key to an actor not entitled to it.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an Administrator, when they define an exam naming one active skill and at least one question with its correct answer, then the exam is stored and readable in full by an Administrator (FR-5.4).
2. **AC-02 — Boundary or failure behavior**: Given an exam definition naming a retired skill, more than one skill, or zero questions, when it is submitted, then it is rejected with a stated reason and nothing is stored (FR-5.4, FR-3.4, SEC-BIZ-3).
3. **AC-03 — Prohibited behavior**: Given any non-Administrator, when they attempt to create or edit an exam, then it MUST NOT take effect (SEC-AUTHZ-6); and given any response shape reachable by a Team Member or Viewer — including error and debug paths — it MUST NOT contain answer-key data in any field (NFR-9.7, SEC-BOUND-3).

## Failure Behavior

- **On Invalid Input**: Reject with the field and reason named; store nothing (SEC-INPUT-1)
- **On Authentication Failure**: Refuse; return no exam data (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without confirming whether the named exam exists (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; no exam stored with a partial question set, and no error response carrying key material (SEC-ERR-1, SEC-ERR-2)
- **Logging / Audit**: Exam create and edit logged with actor, action, target and timestamp (SEC-LOG-2); answer keys MUST NOT appear in logs (SEC-LOG-3)
- **Alerting**: N/A

## Test Strategy

- **Unit Tests**: Exam shape validation — one skill, at least one question, each question with an answer; active-skill check; the storage split that keeps the key out of the delivery projection
- **Integration Tests**: Create-and-read round trip as an Administrator; read as an Assessor asserting the key is absent
- **Security Tests**: The SEC-BOUND-3 sweep asserting every exam-facing response shape reaching a Team Member or Viewer omits answer-key fields, including error and debug paths; privilege tests from each non-Administrator role on create and edit (SEC-AUTHZ-6); a log-scrubbing test asserting no key material is logged (SEC-LOG-3); markup payloads in question text asserted to render literally (SEC-RENDER-1)
- **Compliance Tests / Evidence**: N/A
- **Acceptance-Criteria Traceability**: AC-01 by the round-trip test; AC-02 by the shape-validation suite; AC-03 by the privilege tests and the SEC-BOUND-3 sweep
- **Coverage Target**: Every response shape that can carry exam data covered for key absence, per role
- **Required Test Environment**: The `UT-10.1` fixture plus at least one exam per skill with a known key

## Dependencies

- **Upstream Requirements**: REQ-SKILL-010, REQ-SKILL-020, REQ-AUTH-060, REQ-UIKIT-050
- **Downstream Requirements**: REQ-EXAM-020, REQ-EXAM-030, REQ-EXAM-050, REQ-EXAM-070
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: One exam measures one skill (FR-5.4). Assessment owns exams, questions and answer keys (DR-3), and the key never crosses the API boundary toward an unentitled caller (DR-8).
- **Prohibited Approaches**: Storing the key on the same record the delivery query reads and relying on a field filter; filtering the key in a serializer or view layer (SEC-BOUND-3); including the key in a debug or development-only response shape, which SEC-BOUND-3 covers explicitly
- **Implementation Guidance**: Put the key in its own relation with its own read path, so REQ-EXAM-030's delivery query has no column to forget to exclude. That turns NFR-9.7 from a discipline into a structure.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — data protection and trust boundary (`CLAUDE.md`)
- **Open Decisions**: `OQ-2` is recorded — per-question weights, a pass threshold or a manual review step would change the definition's shape. FR-5.7 as stated needs none of them. `PQ-16` (exam media) is recorded and blocks REQ-EXAM-070 only.
- **Estimated effort**: 1–1.5 engineer-days; 400–650 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — the storage decision here determines whether answer-key confidentiality is structural or merely careful, and NFR-9.7 admits no partial compliance.
