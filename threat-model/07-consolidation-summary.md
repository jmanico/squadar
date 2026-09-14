# 07 — Threat Model Consolidation Summary

**Unified model:** `07-consolidated.cdx.json`
**Sources merged:** `05-repository-recon.cdx.json`, `06-document-absorption.cdx.json`
**Date:** 2026-09-14

---

## Sources processed and their coverage

| Source | Methodology | Contributed | Coverage |
| --- | --- | --- | --- |
| 05 Repository Reconnaissance | Automated Repository Analysis | 16 assets, 7 trust boundaries, 9 flows, 5 findings, the control-status convention | Complete for what exists — which is specifications and development tooling only |
| 06 Document Absorption | Document Analysis | 18 requirement-derived obligations, 8 conflicts, 10 documentation gaps | Primary evidence source for this engagement |

Stage 05 normally leads and stage 06 corroborates. Here the repository is documentation-first, so the
order is reversed: **06 supplies the model and 05 supplies the crucial negative finding** that none of
it is built.

## Merge decisions

**Assets.** No deduplication conflicts arose — both stages drew component names from
`ARCHITECTURE.md`, so the 16 assets merged one-to-one. The Chart Data Service is retained as a
distinct asset despite `ARCHITECTURE.md` noting it may be a responsibility inside the API, because
five threats attach to it specifically.

**Trust boundaries.** Both stages enumerated the same six product boundaries with no contradiction —
unusual, and a credit to the corpus. `tb-7` (developer workstation → repository) was added by stage 05
and is kept, flagged as a development boundary, because it is the only boundary with live controls
today and it carries three real findings (T-13, T-29, T-32).

**Controls.** All 48 `SEC-*` rules and 8 `DEP-*` rules merged as **Specified — Not Implemented**.
The normal consolidator distinction — *Verified in code* versus *Claimed — Not Verified* — collapses
here: nothing can be verified because nothing is built. `SECURITY.md`'s own CONFIRMED / PROVISIONAL
labels were preserved but **reinterpreted as provenance, not implementation status**; treating
CONFIRMED as "in place" would be the single most damaging misreading available in this repository.

**Threats.** 32 threats. Five reconnaissance findings from stage 05 were folded into the threats they
belong to rather than kept separate: `recon-2` → T-32, `recon-3` → T-29, `recon-4` → T-01, `recon-5`
→ T-28; `recon-1` became the model-wide scoring convention rather than a threat. Six of the eight
document conflicts from stage 06 were promoted to threats in their own right (C-1 → T-26, C-2 → T-04,
C-4 → T-25, C-5 → folded into T-02, C-6 → T-16, C-7 → T-14, C-8 → T-15); C-3 (ABAC versus single
role) remains a specification gap behind T-01 and T-02 rather than a threat of its own.

**No cross-methodology deduplication was performed.** Where a STRIDE dimension and a LINDDUN category
describe the same flow — T-04 is Information Disclosure *and* Identifiability *and* Non-compliance —
both are recorded, per the consolidator rule that these are complementary perspectives.

**Risk scoring.** Rated against the convention declared in the model metadata: severity reflects the
risk the design carries into implementation, not current exploitability. Stated plainly so no reader
mistakes this for a report on a running system.

## Threat summary by risk level

| Severity | Count | Threats |
| --- | --- | --- |
| Critical | 2 | T-01 object-level authorization, T-02 privilege escalation to Administrator |
| High | 11 | T-03 answer-key disclosure, T-04 peer score exposure, T-05 JWT verification, T-06 stale authority, T-07 exam result forgery, T-08 assessor out-of-scope writes, T-09 asset reference as entitlement, T-10 recovery and emailed links, T-11 SQL injection in sort/filter, T-12 stored XSS via chart labels, T-13 public infrastructure |
| Medium | 16 | T-14 … T-29 |
| Low | 3 | T-30 email content, T-31 test fixtures, T-32 development boundary |

**Concentration.** Assessment carries 14 of 32 threats and the REST API carries 11 — expected, since
Assessment owns the crown jewels (scores, answer keys, audit) and the API is the sole enforcement
point. **Information Disclosure (13) and Tampering (11) dominate**, which is the right shape for a
system whose product *is* a set of judgements about people.

## Gap analysis

- **Every trust boundary has specified controls and zero implemented ones.** That is the headline, and
  it is a statement about project stage, not about quality.
- **Two boundaries have specification-level gaps as well:** `tb-3`'s asset access-grant mechanism is
  undefined, so `SEC-BOUND-4` is untestable as written; `tb-1`'s session transport is undecided, so
  `SEC-HTTP-3` remains conditional and T-16 cannot be closed.
- **Sensitive flows without a decided encryption mechanism:** `SEC-DATA-1` is PROVISIONAL with key
  management TO BE DECIDED, so every flow carrying personal performance data has an intent, not a
  mechanism.
- **Threats with no control and no mitigation in the corpus:** T-04, T-14 and T-22. The first two are
  specification contradictions the corpus had not caught; the third — unchecked Administrator
  authority over the audit trail that records Administrator actions — is not addressed by any existing
  `SEC-*` rule and needs a new requirement in `REQUIREMENTS.md`.
- **Nine findings are gated on unanswered questions.** `SQ-1` gates T-25 and T-26; `SQ-5` gates T-06,
  T-12 and T-16; `SQ-7` gates T-10 and T-17; `SQ-8` gates T-09, T-13 and T-27; `SQ-9` gates T-08 and
  T-19; `SQ-10` gates T-02; `SQ-11` gates T-15; `OQ-1` gates T-01 and T-04; `OQ-3` gates T-14.
  **Answering eight questions changes the severity or closes the analysis on thirteen threats** —
  cheaper than any control on this list.

## Cross-methodology insights

- **T-01 is confirmed from both directions.** Stage 06 derived it from `FR-1.4`/`SEC-AUTHZ-3`; stage 05
  independently found (`recon-4`) that the authorization matrix exists nowhere as a table, policy or
  fixture. Specified intent plus absent mechanism is the highest-confidence finding in the model.
- **T-12 and T-16 are coupled through one undecided choice.** `SEC-SESSION-4` forbids web storage,
  pushing toward cookies; cookies activate the CSRF rule that `SEC-HTTP-3` leaves conditional. One
  decision (`SQ-5`) resolves an XSS-impact question and a CSRF-applicability question together.
- **T-03 and T-09 are the same loss by two routes.** Answer keys can leak in a payload or as media from
  the asset store. If exams carry no media, half the exposure disappears with the Protected Asset
  Store — worth confirming before building it.
- **T-22 sits outside the STRIDE sweep the corpus performed.** It is found by asking who audits the
  auditor, which is an actor-centric question rather than a flow-centric one.

## Cross-functional coverage report

**No human participated in any session.** This model was produced entirely by automated analysis of
documents and repository contents, so under the pipeline's own standard **all 32 findings are
single-perspective** and the Perspective Coverage Matrix is uniformly one column wide.

| Component | Security | Engineering | Privacy | Business | Operations | ML/Data Science |
| --- | --- | --- | --- | --- | --- | --- |
| REST API | Automated only | Not assessed | Not assessed | Not assessed | Not assessed | N/A |
| Identity & Access | Automated only | Not assessed | Not assessed | Not assessed | Not assessed | N/A |
| Assessment | Automated only | Not assessed | Not assessed | Not assessed | Not assessed | N/A |
| Chart Data Service | Automated only | Not assessed | **Needed** | **Needed** | Not assessed | N/A |
| Roster / Skill Catalog | Automated only | Not assessed | **Needed** | Not assessed | Not assessed | N/A |
| Bulk Import / Export | Automated only | Not assessed | Not assessed | Not assessed | Not assessed | N/A |
| Data stores | Automated only | Not assessed | **Needed** | Not assessed | **Needed** | N/A |
| Terraform infrastructure | Automated only | Not assessed | Not assessed | Not assessed | **Needed** | N/A |

**Recommended follow-up sessions,** in priority order:

1. **Product owner + HR/people operations** — resolve `OQ-1` (peer visibility) and `OQ-3`
   (self-assessment). Two decisions, both blocking, neither answerable by engineering. Closes T-04 and
   T-14 and sharpens T-01.
2. **Privacy officer or legal counsel + product owner** — resolve `SQ-1`. It gates retention, deletion
   semantics, data-subject rights and breach duties (T-25, T-26).
3. **Security engineer + developer, STRIDE (prompt 00)** — validate the 13 Critical and High findings
   against the first implementation design, especially T-01, T-02 and T-03.
4. **DevOps/platform engineer** — answer `SQ-8` so T-13, T-27 and T-29 can be made provider-specific.
5. **Red team, Attack Trees (prompt 03)** — objectives *obtain the answer key* and *alter a colleague's
   score undetected*, which stress T-15 and T-22 better than any flow-centric method.
6. **SRE, FMEA (prompt 04)** — availability at `NFR-9.3` scale, currently represented by T-19 alone.

## Disagreement summary

Three unresolved disagreements are carried forward. All three are **document-level** — the
specifications contradict each other — rather than session-level, because no session was held.

| ID | Question | Tracked as | Owner | Affects |
| --- | --- | --- | --- | --- |
| D-1 | Is regulated personal data in scope? | `SQ-1` | Privacy/legal + product | T-25, T-26 |
| D-2 | May peers see each other's attributed scores? | `OQ-1` | Product + HR | T-04, T-01 |
| D-3 | Should self-assessed scores drive the chart? | `OQ-3` | Product | T-14 |

None should be resolved by an implementer choosing at the keyboard, which is exactly what will happen
if they reach the first PR unanswered.
