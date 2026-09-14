# Squadar Threat Model

Produced 2026-09-14 against commit `6441881` using the CycloneDX Threat Modeling Blueprint 2.0
pipeline. **Start with `10-threat-model-report.md`.**

## Contents

| File | Stage | What it is |
| --- | --- | --- |
| `10-threat-model-report.md` | 10 | **The report.** Executive summary, scope, architecture, 32 threats, risk matrix, control gaps, remediation roadmap, compliance mapping |
| `07-consolidated.cdx.json` | 07 | The unified machine-readable model — all 32 threats with mitigations and residual risk |
| `07-consolidation-summary.md` | 07 | Merge decisions, gap analysis, cross-methodology insights, coverage report |
| `08-diagrams.md` | 08 | Five diagram types in ASCII, Mermaid and Graphviz DOT |
| `05-repository-recon.md` / `.cdx.json` | 05 | Eight-phase repository scan |
| `06-document-absorption.md` / `.cdx.json` | 06 | Extraction from the eight specification documents; the eight conflicts found |

## Read this first

**Squadar has no application code.** Every one of the 48 `SEC-*` rules in `SECURITY.md` is
**Specified — Not Implemented**. Severities in these documents rate the risk the *design* carries into
implementation, not current exploitability. **No finding here asserts a running vulnerability.**

`SECURITY.md`'s CONFIRMED / PROVISIONAL labels describe a rule's provenance, not whether it is built.
Reading CONFIRMED as "in place" is the single most damaging misinterpretation available here.

## The short version

- **2 Critical** — object-level authorization on every identifier-bearing read (T-01); privilege
  escalation to Administrator (T-02).
- **11 High** — answer-key disclosure, peer score exposure, JWT verification, stale authority, exam
  result forgery, assessor scope, asset references, account recovery, SQL injection in sort
  parameters, stored XSS via chart labels, public infrastructure.
- **Two contradictions the specifications had not caught:** the radar chart contradicts the Team
  Member confidentiality rule (T-04), and self-assessment can inflate a member's own charted score
  (T-14).
- **One gap no existing rule covers:** the Administrator can alter employment-relevant records and is
  the sole reader of the audit trail recording it (T-22).
- **Eight unanswered questions gate thirteen findings.** Answering them is the cheapest risk reduction
  available, and none can be answered by an engineer at a keyboard.

## Regenerating

Prompts: `~/Dropbox/github/experimental/prompts/Security Assessment Prompts/Threat Modeling/`.
Re-run stages 05 → 06 → 07 → 08 → 10 after the first implementation PR and diff against
`07-consolidated.cdx.json`; this model is the baseline, since `SECURITY.md` recorded threat model
status as `TO BE COMPLETED`.

Recommended follow-up sessions, in priority order, are in `10-threat-model-report.md` §6.4.
