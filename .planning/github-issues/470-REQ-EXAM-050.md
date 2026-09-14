# [REQ-EXAM-050] Score a submission server-side and convert the percentage to a 1–10 band

## Metadata

- **ID**: REQ-EXAM-050
- **Title**: Score a submission server-side and convert the percentage to a 1–10 band
- **Version**: 1.0.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: Critical
- **Requirement Type**: Functional
- **Source / Parent**: REQ-EXAM-000; `REQUIREMENTS.md` FR-5.7, FR-5.8, FR-5.9, NFR-9.2; `SECURITY.md` SEC-BIZ-1

## Requirement

- **Statement**: On submission of an exam the system MUST score it automatically from the stored answer key, convert the percentage of correct answers to a 1–10 score by dividing the percentage into ten equal bands where 1–10% yields 1, 91–100% yields 10 and 0% yields 1, record the result against the assessed member and the exam's skill, make it available for display immediately, and show the submitting team member their resulting score — all within 5 seconds of submission.
- **Rationale**: FR-5.7 fixes the conversion exactly; FR-5.8 and FR-5.9 fix what happens to the result; NFR-9.2 bounds the latency. SEC-BIZ-1 requires the computation to happen server-side from the stored key, so a client-submitted score or percentage carries no weight.
- **Assumptions**: FR-5.7's band conversion is marked **(assumed)** in `REQUIREMENTS.md` and stands. Every question carries equal weight, since `OQ-2` leaves per-question weights unresolved and FR-5.7 as written implies none.
- **Out of Scope**: Whether this submission constitutes a valid attempt (REQ-EXAM-040, blocked on `PQ-4`); pass thresholds and manual review (`OQ-2`).
- **Design Traceability**: `DESIGN.md` — Components (Buttons: exam submission shows a busy state and stays disabled until it resolves, rather than being clickable twice), Form feedback and errors (success is confirmed in text in `success` and persists until the user moves on), Brand direction (nothing gamifies a low score — the result is reported, not celebrated or lamented).
- **Architecture Traceability**: `ARCHITECTURE.md` Assessment — automatic scoring and the percentage-to-1–10 band conversion, and immediate availability of the result; Primary Flow 3; DR-3.
- **Security Traceability**: SEC-BIZ-1, SEC-INPUT-3, SEC-INPUT-2, SEC-BOUND-1, SEC-BOUND-3, SEC-LOG-1, SEC-LOG-3, SEC-ERR-2, SEC-HTTP-5.

## Scope

- **Applies To**: Multiple
- **Components**: Assessment; REST API; Web Client
- **Interfaces / Operations**: Exam submission; automatic scoring; result display to the submitting member
- **Actors**: Team Member (submitter); the score is recorded against them
- **Preconditions**: REQ-EXAM-030, REQ-SCORE-050 and REQ-SCORE-060 are Verified; the exam's skill is active
- **Data Classification**: Restricted
- **Personal or Regulated Data**: Personal Data
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`

## Security Context

- **Security Objectives**: Integrity, Authenticity, Availability
- **Control Layers**: Business-Rule Validation, Input Validation, Availability
- **Threat References**: STRIDE — Tampering; OWASP Top 10:2025 Broken Access Control; CWE-602 Client-Side Enforcement of Server-Side Security; CWE-807 Reliance on Untrusted Inputs in a Security Decision
- **Abuse / Misuse Case**: A submission carrying a forged `score` or `percentage` field that the server honours; a submission whose answers are scored against a client-supplied key; an oversized or repeated submission used to exhaust scoring capacity.
- **Trust Boundary**: Clients → REST API → Assessment
- **Untrusted Inputs or Assertions**: The submitted answers and every other field in the submission, including any score or percentage
- **Authoritative Enforcement Point**: Assessment, computing from the stored answer key alone (SEC-BIZ-1)
- **Independent Verification**: A submission test including a forged score field, asserting the recorded score derives from the answers only (SEC-BIZ-1)
- **Zero Trust Relevance**: N/A — this is server-side derivation, not a resource-access decision

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`; the applicable chapter is Validation and Business Logic
- **OWASP AISVS 1.0**: N/A — scoring is deterministic arithmetic against a stored key, with no AI-enabled component
- **NIST SP 800-53 Rev. 5**: N/A
- **NIST SP 800-207**: N/A
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: N/A
- **Mapping Basis**: CWE-602 is cited because the specific prohibition in SEC-BIZ-1 is exactly reliance on a client-computed result for a decision the server owns.

## Acceptance Criteria

1. **AC-01 — Expected behavior**: Given an assigned exam of 10 equally weighted questions, when a Team Member submits 7 correct answers, then the percentage is 70%, the recorded score is 7, it is stamped with the exam method and the exam as its source, an audit entry is written, the submitting member is shown the score, and the whole sequence completes within 5 seconds (FR-5.7, FR-5.8, FR-5.9, NFR-9.2, SEC-LOG-1).
2. **AC-02 — Boundary or failure behavior**: Given submissions scoring 0%, 1%, 10%, 11%, 90%, 91% and 100%, when each is scored, then the resulting scores are 1, 1, 1, 2, 9, 10 and 10 respectively (FR-5.7).
3. **AC-03 — Prohibited behavior**: Given a submission carrying a `score` or `percentage` field, when it is scored, then that value MUST NOT influence the result — the recorded score derives from the submitted answers and the stored key alone (SEC-BIZ-1, SEC-INPUT-3).

## Failure Behavior

- **On Invalid Input**: Reject the submission; record no attempt result and no score (SEC-INPUT-1)
- **On Authentication Failure**: Refuse (SEC-AUTHN-1)
- **On Authorization Failure**: Deny without disclosing the exam's existence or content (SEC-AUTHZ-7)
- **On Security-Decision Failure**: Deny by default (SEC-AUTHZ-1)
- **On External Dependency Failure**: N/A
- **On System Error**: Roll back; never an exam scored without its audit entry, nor a score recorded without its history entry (SEC-ERR-2)
- **Logging / Audit**: The resulting score produces one audit entry naming the acting user, the member, the skill, the method and the timestamp (SEC-LOG-1); answers, answer keys and score values MUST NOT appear in general logs (SEC-LOG-3)
- **Alerting**: TO BE DECIDED — depends on `PQ-10`

## Test Strategy

- **Unit Tests**: The percentage computation; the band conversion at every boundary — 0%, 1%, 10%, 11%, 20%, 21%, 90%, 91%, 100% — and at each band's two edges; behavior with an all-wrong and an all-correct submission
- **Integration Tests**: Primary Flow 3 end to end asserting the score is recorded with provenance, audited, shown to the submitter and immediately readable; an NFR-9.2 timing test against the fixture; a subsequent chart read picking up the new current score (FR-5.10, tested fully in REQ-EXAM-060)
- **Security Tests**: A submission including a forged `score` field asserting the recorded score derives from the answers only (SEC-BIZ-1); mass-assignment tests on method, source and recorded date (SEC-INPUT-3); a direct API submission bypassing both clients (SEC-BOUND-1); request-rate and request-size limits on the submission endpoint (SEC-HTTP-5); a log-scrubbing test (SEC-LOG-3)
- **Compliance Tests / Evidence**: WCAG 2.2 AA — the result is announced as text, not conveyed by colour, and the submit control's busy state is announced
- **Acceptance-Criteria Traceability**: AC-01 by the end-to-end flow test; AC-02 by the band-boundary suite; AC-03 by the forged-score test
- **Coverage Target**: Every band boundary on both sides, plus the 0% special case; positive and negative coverage on the derivation
- **Required Test Environment**: The `UT-10.1` fixture plus exams with known keys and question counts that make each band boundary reachable exactly

## Dependencies

- **Upstream Requirements**: REQ-EXAM-010, REQ-EXAM-030, REQ-SCORE-020, REQ-SCORE-040, REQ-SCORE-050, REQ-SCORE-060
- **Downstream Requirements**: REQ-EXAM-060, REQ-CHART-010, REQ-PORT-010
- **External Dependencies**: None
- **Dependency Assumptions**: N/A
- **Failure Impact**: N/A

## Implementation Notes

- **Constraints**: The conversion is exactly FR-5.7's — ten equal bands, 1–10% yields 1, 91–100% yields 10, 0% yields 1. The 0% case is a stated special case, not a rounding artifact, and must be implemented as such.
- **Prohibited Approaches**: Computing the score in the client (SEC-BIZ-1, DR-1); honouring a submitted score or percentage; per-question weighting, which `OQ-2` leaves unresolved and FR-5.7 does not provide for; deferring the audit write outside the transaction (SEC-ERR-2)
- **Implementation Guidance**: Write the band conversion as a single pure function and test it exhaustively at the boundaries — it is the one piece of arithmetic in the product whose off-by-one would be invisible in normal use and wrong for every person it touched.
- **AI Development Guidance**: `CLAUDE.md`; `.claude/agents/security-reviewer.md` before the pull request
- **Required Human Review**: Human security review before merge — business-rule validation at a trust boundary (`CLAUDE.md`); product review of the band table
- **Open Decisions**: `OQ-2` is recorded — weights, thresholds or manual review would change this conversion. `PQ-4` blocks REQ-EXAM-040, not this issue: the arithmetic is the same whatever the attempt policy.
- **Estimated effort**: 1–1.5 engineer-days; 350–600 changed human-authored lines
- **Recommended model**: Claude Opus 5 (`claude-opus-5`) — a security-relevant derivation that must be immune to client input, coupled transactionally to history and audit, with an exactly specified band table that admits no approximation.
