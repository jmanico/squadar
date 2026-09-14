# Squadar — Architecture

Scope: HOW the system is built — components, interfaces, data flow, trust boundaries, technology
choices and their rationale. `REQUIREMENTS.md` owns system behavior; `DESIGN.md` owns visual language,
interaction conventions and frontend capability expectations. Detailed security controls are deferred
to `SECURITY.md`.

Markers: `UNKNOWN` — the input documents do not provide the fact. `TO BE DECIDED` — the decision has
not been made. `ASSUMPTION` — an inference not supported by an input source.

## Required Architecture Inputs

- Requirements source: REQUIREMENTS.md
- Design source: DESIGN.md
- System purpose: See REQUIREMENTS.md
- Primary use cases: See REQUIREMENTS.md
- Target users / actors: See REQUIREMENTS.md
- Runtime environment: web application and mobile app that use the same API
- Server framework: Node.js
- Client framework: React.js for web, React Native for mobile
- API style and integration model: REST
- Authentication and session model: passkey/password + OIDC
- Data model expectations: RBSMS third normal form, and large assets like movie files go in protected folders (not the DB)
- Deployment model: teraform
- Scale expectations: enterprise
- Security expectations: see `SECURITY.md`, which owns the threat model and all `SEC-*` and `DEP-*` rules

## Initial Architecture (Provisional)

Both clients are public, untrusted code; DR-1 below states what follows from that.

The trust boundary runs between the clients and the REST API. A second boundary runs between the API
and the identity provider (OIDC). A third runs at the protected asset store, which holds large binary
assets (e.g. exam media) outside the relational database per the architecture notes; it is reachable
only through authorization decisions the API makes.

**Business object ownership.** Identity & Access owns users, roles and sessions. Roster owns team
members and teams. Skill Catalog owns skills. Assessment owns scores, score history, exams, exam
attempts and audit entries. No component mutates another's objects; it asks the owner.

### Components

- **Web Client (React.js)**
  - **Responsibility:** Render all screens for the four roles; selection of members and skills; radar
    chart and its equivalent score table; exam taking; forms. Implements the design language,
    responsive grid and WCAG 2.2 AA conformance defined in `DESIGN.md`, which is the sole source of
    those values. Presents client-side validation as a courtesy layer only (DR-1).
  - **Inputs:** User interaction; REST responses; authenticated session credentials.
  - **Outputs:** REST requests; rendered UI.
  - **Data owned or accessed:** Owns no durable data. Holds transient view state (current selection,
    series visibility per FR-7.11, theme preference).
  - **Open decisions:** Radar chart rendering approach and library — TO BE DECIDED. Client state
    management and build tooling — TO BE DECIDED. Whether chart series geometry is computed client-side
    or returned by the API — TO BE DECIDED.

- **Mobile Client (React Native)**
  - **Responsibility:** Same product surface and the same design and accessibility obligations as the
    Web Client, on mobile. Consumes the identical REST API; no mobile-only endpoints.
  - **Inputs:** User interaction; REST responses; authenticated session credentials.
  - **Outputs:** REST requests; rendered UI.
  - **Data owned or accessed:** Owns no durable data. Transient view state as above.
  - **Open decisions:** Which screens are in the mobile scope at launch — UNKNOWN. Offline behavior —
    TO BE DECIDED. Platform passkey integration details — TO BE DECIDED.

- **REST API (Node.js)**
  - **Responsibility:** The single entry point for both clients and the sole enforcement point for
    authorization and business rules. Authenticates every request (FR-1.1), resolves the caller's role
    (FR-1.2) and refuses impermissible requests without disclosing withheld data (FR-1.7). Routes to
    the owning domain component; shapes responses; enforces request-level concerns (pagination, limits).
  - **Inputs:** HTTP requests from the two clients; verified identity assertions from Identity & Access.
  - **Outputs:** HTTP responses; calls into domain components; audit events.
  - **Data owned or accessed:** None directly — reaches all data through the owning component.
  - **Open decisions:** API versioning scheme, error response format, pagination convention, and whether
    the domain components are modules inside one deployable or separate services — TO BE DECIDED.

- **Identity & Access**
  - **Responsibility:** Authentication via passkey/password and OIDC; session establishment and
    lifetime; role assignment (FR-1.2, FR-1.3); producing the authorization context — role, the teams
    an Assessor is assigned to (FR-1.5), the team member a user corresponds to (FR-1.4) — that the API
    and domain components evaluate against.
  - **Inputs:** Credential and OIDC flows; Administrator account and role changes.
  - **Outputs:** Verified identity and authorization context; session validity decisions.
  - **Data owned or accessed:** Owns users, credentials, role assignments and sessions. Reads Roster to
    link a user to a team member.
  - **Open decisions:** OIDC provider(s) and whether the system is also its own issuer — UNKNOWN.
    Session transport and lifetime, and the boundary between passkey/password and OIDC paths — TO BE
    DECIDED. Detailed controls — `SECURITY.md`.

- **Roster (Team Members and Teams)**
  - **Responsibility:** Team member records and lifecycle (FR-2.1–FR-2.3), including retaining a
    deactivated member's history while excluding them from new assessments; named teams with persistent
    membership and many-to-many membership (FR-2.4, FR-2.5); ad-hoc selection sets for display
    (FR-2.6); personal-data deletion on request (FR-8.4).
  - **Inputs:** Administrator create/edit/deactivate/delete commands; team save and reopen; import rows
    from Bulk Import.
  - **Outputs:** Member and team records; membership answers used for authorization and charting;
    deletion events consumed by Assessment.
  - **Data owned or accessed:** Owns team members, teams and team membership.
  - **Open decisions:** Whether FR-8.4 deletion is erasure or irreversible anonymization, and its effect
    on audit entries (NFR-9.6) — TO BE DECIDED. Whether team assembly ever means recommendation rather
    than manual selection — UNKNOWN (OQ-6).

- **Skill Catalog**
  - **Responsibility:** The single system-wide skill catalog (FR-3.1); add, rename, retire (FR-3.2);
    rejection of duplicate active names (FR-3.3); retired skills remain scoreable in history but are
    not offered for new assessments (FR-3.4). Supplies the axis candidates for chart configuration
    (FR-7.5).
  - **Inputs:** Administrator catalog commands; import rows from Bulk Import.
  - **Outputs:** Skill records; active/retired status; axis candidate lists.
  - **Data owned or accessed:** Owns skills.
  - **Open decisions:** Whether skills are grouped or categorized — UNKNOWN.

- **Assessment (Scores, Exams, Attempts)**
  - **Responsibility:** The business core. Validates and records scores as integers 1–10 (FR-4.2,
    FR-4.3); keeps at most one current score per member per skill while retaining full history
    (FR-4.1, FR-4.6); distinguishes unassessed from scored 1 (FR-4.4); stamps method, source and date
    on every score (FR-4.5, FR-5.3, FR-5.11). Supports exam, assessor-rating and self-assessment
    methods (FR-5.1, FR-5.2). Owns exam definitions and answer keys, assignment (FR-5.5), the rule
    that only an assigned member may attempt an exam (FR-5.6), automatic scoring and the
    percentage-to-1–10 band conversion (FR-5.7), and immediate availability of the result (FR-5.8,
    FR-5.9). Answer keys never leave this component toward a Team Member or Viewer (NFR-9.7). Produces
    ranked and tabular views (FR-6.1–FR-6.3) and the current-score data behind every radar chart,
    including the absent-score signal (FR-7.9). Writes an audit entry for every score create, change
    or delete (NFR-9.6).
  - **Inputs:** Assessor and self ratings; exam definitions and assignments; exam submissions; member
    and skill references from Roster and Skill Catalog; deletion events from Roster.
  - **Outputs:** Current scores and history; exam results; ranked lists; chart datasets; audit entries;
    a team member's exportable record (FR-8.3).
  - **Data owned or accessed:** Owns skill scores, score history, assessment records, exams, exam
    questions and answer keys, exam attempts and score audit entries. References members (Roster) and
    skills (Skill Catalog) by identity; never mutates them.
  - **Open decisions:** Whether self-assessed scores count as the current score on a chart — UNKNOWN
    (OQ-3). Score expiry or decay — UNKNOWN (OQ-4). Per-question weights, pass thresholds or manual
    review — UNKNOWN (OQ-2). Exam attempt timing, resumption and retake policy — UNKNOWN.

- **Chart Data Service** *(a responsibility within the API, not necessarily a separate deployable)*
  - **Responsibility:** Assembles a chart dataset for a selection of members and skills: one shared
    axis set for every series (FR-7.4), each member's current score per axis, explicit absence markers
    (FR-7.9), and enforcement of the 3–12 axis and ≥6 member limits with a reported reason when a
    selection falls outside them (FR-7.6, FR-7.7). Returns an empty-state result when no member is
    selected (FR-7.10). The same dataset backs the chart and its equivalent score table (FR-6.2), so
    the two can never disagree. Meets NFR-9.1 and NFR-9.3 for the maximum supported selection.
  - **Inputs:** A selection of team members and skills with the caller's authorization context.
  - **Outputs:** One chart dataset consumed identically by both clients.
  - **Data owned or accessed:** Reads from Assessment, Roster and Skill Catalog. Owns nothing.
  - **Open decisions:** Whether any read model or caching is needed to hold NFR-9.1 at NFR-9.3 scale —
    TO BE DECIDED.

- **Bulk Import / Export**
  - **Responsibility:** Parses delimited bulk import of team members and skills and reports per-row
    rejections with reasons (FR-8.2); produces a team member's machine-readable record export (FR-8.3).
    It validates shape and then submits each row through the owning component, so imported data passes
    the same rules as interactively entered data (FR-8.1).
  - **Inputs:** Administrator-supplied delimited files; export requests.
  - **Outputs:** Per-row accept/reject reports; export documents.
  - **Data owned or accessed:** Owns nothing durable; writes through Roster and Skill Catalog, reads
    through Assessment for export.
  - **Open decisions:** File format specifics, size limits, and whether large imports run synchronously
    or as background work — TO BE DECIDED.

- **Relational Data Store**
  - **Responsibility:** Durable persistence in third normal form per the architecture notes; enforces
    relational integrity for the constraints the domain depends on (one current score per member per
    skill, unique active skill name, team membership).
  - **Inputs:** Reads and writes from the owning domain components only.
  - **Outputs:** Persisted records.
  - **Data owned or accessed:** Stores all structured data; owns none of it semantically.
  - **Open decisions:** Database product — TO BE DECIDED. Schema, indexing and history-table shape —
    TO BE DECIDED.

- **Protected Asset Store**
  - **Responsibility:** Holds large binary assets (e.g. exam media) in protected folders outside the
    relational database per the architecture notes. The database holds references, never the bytes.
    Access is granted only per an authorization decision made by the API, so an asset URL is not itself
    an entitlement.
  - **Inputs:** Asset writes from Assessment; authorized read requests.
  - **Outputs:** Asset bytes or authorized access grants.
  - **Data owned or accessed:** Stores asset files; Assessment owns the references and their meaning.
  - **Open decisions:** Storage technology and access-grant mechanism — TO BE DECIDED. Detailed
    controls — `SECURITY.md`. Whether exams carry media at all — UNKNOWN (ASSUMPTION: the "movie files"
    example in the architecture notes implies media-bearing exam content).

- **Outbound Notification**
  - **Responsibility:** The only external integration in `REQUIREMENTS.md`: outbound transactional email
    for exam invitations and account access. It is a delivery edge, not a decision point — it sends what
    a domain component asks it to send.
  - **Inputs:** Notification requests from Assessment (exam assignment) and Identity & Access (account
    access).
  - **Outputs:** Outbound messages to an external mail provider; delivery outcomes.
  - **Data owned or accessed:** Owns nothing; reads the minimum needed per message.
  - **Open decisions:** Mail provider — TO BE DECIDED. Retry, bounce handling and whether sending is
    synchronous or queued — TO BE DECIDED.

### Primary Flows

1. **Authenticate.** Client → REST API → Identity & Access (passkey/password or OIDC) → session and
   authorization context. No data flows before this (FR-1.1).
2. **Render a shared radar chart.** Client sends a member and skill selection → API authorizes the
   caller against Roster membership and role → Chart Data Service assembles one dataset from
   Assessment, Roster and Skill Catalog, applying the axis and member limits → client renders chart and
   equivalent score table from the same payload (FR-6.2, FR-7.1–FR-7.11).
3. **Take and score an exam.** Client requests an assigned exam → Assessment returns questions without
   answer keys (NFR-9.7) → client submits answers → Assessment scores, converts to 1–10 (FR-5.7),
   records the score with method and source, writes an audit entry, and returns the result (FR-5.8,
   FR-5.9). Subsequent chart reads pick up the new current score automatically (FR-5.10).
4. **Record a rating.** Assessor or self submits a score → API authorizes (FR-1.5) → Assessment
   validates 1–10, supersedes the prior current score into history, stamps method and date, writes an
   audit entry.
5. **Administer catalog, accounts and roster.** Administrator commands → API authorizes (FR-1.3) →
   Skill Catalog, Identity & Access or Roster applies the change under its own rules.

## Requirement Traceability

| Requirement group | Component / boundary | Status |
| --- | --- | --- |
| FR-1.1–FR-1.7 (Accounts and Authorization) | Identity & Access; REST API (enforcement point) | SUPPORTED |
| FR-2.1–FR-2.6 (Team Members and Teams) | Roster | SUPPORTED |
| FR-3.1–FR-3.4 (Skill Catalog) | Skill Catalog | SUPPORTED |
| FR-4.1–FR-4.6 (Skill Scores) | Assessment; Relational Data Store (integrity) | SUPPORTED |
| FR-5.1–FR-5.11 (Assessment and Measurement) | Assessment; Web/Mobile Clients (exam UI); Outbound Notification (FR-5.5 invitations); Protected Asset Store (exam media, if any) | SUPPORTED |
| FR-6.1–FR-6.3 (Ranking) | Assessment; Chart Data Service (FR-6.2 table parity); Web/Mobile Clients | SUPPORTED |
| FR-7.1–FR-7.11 (Radar Chart Visualization) | Chart Data Service; Web/Mobile Clients | PARTIALLY DEFINED — rendering approach and where series geometry is computed are TO BE DECIDED |
| FR-8.1 (UI data entry) | Web/Mobile Clients; Roster; Skill Catalog | SUPPORTED |
| FR-8.2 (Bulk import) | Bulk Import / Export | PARTIALLY DEFINED — file format and sync/async execution TO BE DECIDED |
| FR-8.3 (Self export) | Bulk Import / Export; Assessment | SUPPORTED |
| FR-8.4 (Deletion on request) | Roster; Assessment (cascading score removal) | PARTIALLY DEFINED — erasure vs. anonymization and audit interaction TO BE DECIDED |
| NFR-9.1, NFR-9.3 (Chart performance and scale) | Chart Data Service; Relational Data Store | PARTIALLY DEFINED — no read model, indexing or caching decision made |
| NFR-9.2 (Exam scoring latency) | Assessment | SUPPORTED |
| NFR-9.4, NFR-9.5 (Non-color encoding, keyboard) | Web Client; Mobile Client (per `DESIGN.md`) | SUPPORTED |
| NFR-9.6 (Score audit trail) | Assessment | SUPPORTED |
| NFR-9.7 (Answer-key confidentiality) | Assessment; REST API | SUPPORTED |
| `DESIGN.md` WCAG 2.2 AA, themes, responsive grid, chart conventions | Web Client; Mobile Client | SUPPORTED |
| Security controls | All boundaries and components | SPECIFIED in `SECURITY.md` (`SEC-*`, `DEP-*`); individual rules carry their own status there |
| OQ-1 … OQ-6 | — | TO BE DECIDED — unresolved product questions in `REQUIREMENTS.md` |

## Dependency Rules

- **DR-1** No business rule may exist only in a client. Every authorization decision, validation and
  derivation stated in `REQUIREMENTS.md` is enforced server-side; a client check is a usability
  courtesy and is always duplicated behind the API boundary. The two clients are interchangeable
  consumers, and neither may be trusted more than the other.
- **DR-2** Both clients depend on the REST API only, through the same documented contract. Neither
  client reaches the data store, the asset store, or any domain component directly, and no endpoint
  exists to serve only one client.
- **DR-3** Each business object has exactly one owning component (Identity & Access: users, roles,
  sessions; Roster: team members and teams; Skill Catalog: skills; Assessment: scores, history, exams,
  attempts, audit). Only the owner may mutate its objects; every other component requests the change
  through the owner's interface and may otherwise only read.
- **DR-4** Dependencies cross documented interfaces only — no component reads another's tables,
  internal state or storage layout. Shared persistence is not a shared interface.
- **DR-5** The dependency graph is acyclic. Clients → API → domain components → persistence and
  external edges. A domain component never calls back into the API, and where two domain components
  would otherwise depend on each other, one publishes an event the other consumes (e.g. Roster
  deletion consumed by Assessment).
- **DR-6** External systems (the OIDC provider, the mail provider, the asset store) are reached only
  through an adapter owned by the component that needs them. No vendor type, error, identifier or
  payload shape crosses out of that adapter; the rest of the system sees only domain terms, so a
  provider can be replaced without touching a domain component.
- **DR-7** Derived and presentational data has one source. The radar chart and its equivalent score
  table are rendered from a single dataset produced by the Chart Data Service (FR-6.2), never from two
  independent computations.
- **DR-8** Answer keys and other withheld data never cross the API boundary toward a caller not
  entitled to them — filtering happens in the owning component, not in a client or a view layer
  (NFR-9.7, FR-1.7).
- **DR-9** Large binary assets live in the protected asset store and are referenced from the relational
  store, never embedded in it. Access to an asset requires a live authorization decision from the API;
  possession of a reference is not entitlement.
- **DR-10** No rule above names a framework, database, cloud provider or deployment topology, and none
  becomes invalid once those are chosen. Components are defined by boundary and ownership, so they may
  be realized as modules in one deployable or as separate services without changing any rule here.
