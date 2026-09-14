# Squadar — Security

Scope: the security posture of Squadar — threat model, security requirements, controls and
trust-boundary enforcement. `REQUIREMENTS.md` owns behavior, actors, workflows, data and privacy
constraints; `ARCHITECTURE.md` owns components, boundaries, flows and dependency direction;
`DESIGN.md` owns browser-facing rendering and input behavior. This document adds security
constraints; where one appears to conflict with those documents it is recorded under
`Open Security Questions` rather than silently overriding them.

Markers: `UNKNOWN` — the input documents do not provide the fact. `TO BE DECIDED` — the decision has
not been made. `ASSUMPTION` — an inference not supported by an input source. No implementation
exists yet; every rule here is prospective and nothing below asserts that any control has been built,
tested or assessed.

## Required Security Inputs

- **Requirements source:** `REQUIREMENTS.md`
- **Design source:** `DESIGN.md`
- **Architecture source:** `ARCHITECTURE.md`
- **System purpose:** Assess and measure team members' skills (including by exam), rank each skill
  1–10, and display multiple members' skills together on a shared radar chart (`REQUIREMENTS.md`).
- **Application profile:** Authenticated multi-user enterprise web application (React.js) and mobile
  application (React Native) over a shared REST API (Node.js) with a relational data store and a
  protected asset store (`ARCHITECTURE.md`). No unauthenticated product surface (FR-1.1).
- **Users / actors / roles:** Administrator, Assessor, Team Member, Viewer (FR-1.2, marked
  **(assumed)** in `REQUIREMENTS.md`). Non-human actors: the OIDC provider and the outbound mail
  provider (`ARCHITECTURE.md`).
- **Public interfaces and trust boundaries:** (1) Web Client / Mobile Client → REST API — the primary
  and sole enforcement boundary (DR-1, DR-2); (2) REST API ↔ Identity & Access ↔ OIDC provider;
  (3) API → Protected Asset Store, reachable only via a live API authorization decision (DR-9);
  (4) domain components → Relational Data Store; (5) Outbound Notification → external mail provider;
  (6) Bulk Import ingest of Administrator-supplied delimited files (FR-8.2). The two clients are
  public, untrusted code.
- **Sensitive or regulated data:** Personal performance data about identifiable individuals — skill
  scores and score history, exam attempts and results, assessment records, audit entries
  (`REQUIREMENTS.md`). Exam questions and answer keys are confidential system data (NFR-9.7).
  Authentication credentials, passkey public-key material and session tokens (Identity & Access).
  `REQUIREMENTS.md` states no special-category or regulated data is stored; the security notes
  nevertheless name GDPR and CCPA — see `SQ-1`.
- **External integrations:** OIDC identity provider (provider(s) `UNKNOWN`); outbound transactional
  email for exam invitations and account access (provider `TO BE DECIDED`); Protected Asset Store
  (technology and access-grant mechanism `TO BE DECIDED`).
- **Authentication model:** Passkey/password + OIDC. Passkeys are explicitly selected, so
  WebAuthn/FIDO guidance applies. Concrete parameters (password policy, passkey attestation and
  recovery, OIDC flow and provider, MFA for password logins) are `TO BE DECIDED`.
- **Authorization model:** ABAC — attribute-based authorization decisions. Confirmed attributes from
  `REQUIREMENTS.md`: the actor's single role (FR-1.2), the teams an Assessor is assigned to (FR-1.5),
  the team member a user corresponds to (FR-1.4), and shared-team membership for chart access
  (FR-1.4). The policy language, decision-point placement and attribute source of record are
  `TO BE DECIDED`. `REQUIREMENTS.md` describes a single-role model; see `SQ-2`.
- **Session model:** JWT. Token type split (access/refresh), transport, storage on each client,
  lifetime, revocation and signing algorithm are all `TO BE DECIDED`.
- **Deployment and CI/CD model:** Infrastructure defined as code with Terraform (`ARCHITECTURE.md`,
  security notes). Cloud provider, CI system, runtime topology, state backend and artifact registry
  are `UNKNOWN`.
- **Applicable privacy or regulatory obligations:** Security notes state the education context is
  protected by GDPR and CCPA. Jurisdiction, establishment, data-subject residency and controller /
  processor roles are `UNKNOWN`, so the concrete obligations are `TO BE DECIDED` (`SQ-1`). No other
  regime (HIPAA, PCI DSS, SOC 2, FERPA) is assumed.
- **Security verification reference:** OWASP ASVS 5.0.0. The target verification level is
  `TO BE DECIDED` (`SQ-3`).
- **Threat model status:** `TO BE COMPLETED`. The boundaries above are enumerated, but no structured
  per-flow threat enumeration, ranking or residual-risk acceptance has been performed.

The client/server integration model is resolved: `ARCHITECTURE.md` names a REST API consumed by both
clients. API style guidance therefore applies. Whether that API is exposed as a separately consumable
public/partner API, versus an internal contract for the two first-party clients only, is
`TO BE DECIDED` (`SQ-4`); no third-party API programme is assumed here.

## Selected Security References and Prompt Imports

No secure-coding prompt library was found in the execution environment. `.claude/` in this repository
holds the enforcement layer (settings, agents, commands and hooks), which references the rules below by
ID and reads this document at runtime; it contains no rule text of its own and none was imported. The
public sources below were selected for this stack — authenticated REST API on
Node.js, React and React Native clients, passkeys/password/OIDC, JWT sessions, relational storage,
Terraform-managed infrastructure, personal performance data.

| ID | Source | Version | URL |
| --- | --- | --- | --- |
| `REF-ASVS-5` | OWASP Application Security Verification Standard | 5.0.0 | https://github.com/OWASP/ASVS/releases/tag/v5.0.0_release |
| `REF-PC-2024` | OWASP Top 10 Proactive Controls | 2024 | https://top10proactive.owasp.org/archive/2024/the-top-10/ |
| `REF-API-2023` | OWASP API Security Top 10 | 2023 | https://owasp.org/API-Security/editions/2023/en/0x11-t10/ |
| `REF-REST` | OWASP REST Security Cheat Sheet | current | https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html |
| `REF-AUTH` | OWASP Authentication Cheat Sheet | current | https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html |
| `REF-SESSION` | OWASP Session Management Cheat Sheet | current | https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html |
| `REF-XSS` | OWASP Cross Site Scripting Prevention Cheat Sheet | current | https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html |
| `REF-INPUT` | OWASP Input Validation Cheat Sheet | current | https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html |
| `REF-SECRETS` | OWASP Secrets Management Cheat Sheet | current | https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html |
| `REF-LOG` | OWASP Logging Cheat Sheet | current | https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html |
| `REF-ERROR` | OWASP Error Handling Cheat Sheet | current | https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html |
| `REF-NIST-63B` | NIST SP 800-63B-4, Digital Identity Guidelines: Authentication and Authenticator Management | 800-63B-4 | https://pages.nist.gov/800-63-4/sp800-63b.html |
| `REF-PASSKEY` | FIDO Alliance Passkeys | current | https://fidoalliance.org/passkeys/ |
| `REF-WEBAUTHN` | W3C Web Authentication | current | https://www.w3.org/TR/webauthn/ |
| `REF-SSDF` | NIST SP 800-218, Secure Software Development Framework | 1.1 | https://csrc.nist.gov/pubs/sp/800/218/final |
| `REF-CICD` | OWASP CI/CD Security Cheat Sheet | current | https://cheatsheetseries.owasp.org/cheatsheets/CI_CD_Security_Cheat_Sheet.html |
| `REF-SUPPLY` | OWASP Software Supply Chain Security Cheat Sheet | current | https://cheatsheetseries.owasp.org/cheatsheets/Software_Supply_Chain_Security_Cheat_Sheet.html |
| `REF-IAC` | OWASP Infrastructure as Code Security Cheat Sheet | current | https://cheatsheetseries.owasp.org/cheatsheets/Infrastructure_as_Code_Security_Cheat_Sheet.html |
| `REF-DEP` | OWASP Vulnerable Dependency Management Cheat Sheet | current | https://cheatsheetseries.owasp.org/cheatsheets/Vulnerable_Dependency_Management_Cheat_Sheet.html |

Rules below are synthesized for Squadar, not copied. ASVS is referenced generally: no ASVS 5.0.0
requirement identifier is cited here, because none has been verified against the published standard
text in this environment.

## Provisional Security Rules

Each rule states one verifiable behavior. `CONFIRMED` marks a rule traceable to a stated requirement,
architecture rule or security note; `PROVISIONAL` marks a safe default chosen here that the input
documents do not state.

### Trust boundaries and server-side enforcement

- **SEC-BOUND-1** (CONFIRMED) The REST API MUST enforce every authorization decision, score
  validation, exam-scoring derivation and chart selection limit server-side; a check performed in the
  Web Client or Mobile Client MUST NOT be the only place that rule exists.
  - **Applies to:** Client → REST API boundary; all of FR-1.x, FR-4.2, FR-4.3, FR-5.7, FR-7.6, FR-7.7
  - **Verification:** API-level tests that bypass both clients and submit rule-violating requests
    directly, asserting refusal
  - **References:** `REF-ASVS-5`, `REF-PC-2024`, `REF-API-2023`
- **SEC-BOUND-2** (CONFIRMED) The REST API MUST NOT expose any endpoint, parameter or response field
  that is served to one client and not the other, and MUST NOT treat the Mobile Client as more
  trusted than the Web Client.
  - **Applies to:** REST API surface (DR-2)
  - **Verification:** Contract test asserting one documented endpoint set, exercised identically with
    each client's user agent and build identifiers
  - **References:** `REF-API-2023`
- **SEC-BOUND-3** (CONFIRMED) Data a caller is not entitled to — exam answer keys above all — MUST be
  excluded inside the owning component before a response is assembled, and MUST NOT be filtered in a
  serializer, view layer or client.
  - **Applies to:** Assessment component; NFR-9.7, FR-1.7, DR-8
  - **Verification:** Test asserting that every exam-facing response shape reaching a Team Member or
    Viewer omits answer-key fields, including error and debug paths
  - **References:** `REF-API-2023`, `REF-ASVS-5`
- **SEC-BOUND-4** (PROVISIONAL) The Protected Asset Store MUST NOT serve an asset on possession of a
  reference alone; each read MUST require a live authorization decision from the API, and any grant
  issued MUST be scoped to one asset and time-bounded.
  - **Applies to:** API → Protected Asset Store boundary (DR-9)
  - **Verification:** Test that an asset reference obtained by an entitled actor fails for an
    unentitled actor and after grant expiry. Grant mechanism and lifetime: `TO BE DECIDED`
  - **References:** `REF-ASVS-5`, `REF-PC-2024`

### Authentication

- **SEC-AUTHN-1** (CONFIRMED) The REST API MUST authenticate every request that returns or modifies
  team member, score, exam, chart or account data, and MUST return no such data to an unauthenticated
  caller.
  - **Applies to:** All product endpoints; FR-1.1
  - **Verification:** Automated sweep of the documented endpoint list with no credentials, asserting
    refusal and an empty body of product data
  - **References:** `REF-AUTH`, `REF-ASVS-5`
- **SEC-AUTHN-2** (CONFIRMED) Authentication MUST be performed by Identity & Access through a passkey
  (WebAuthn), password, or OIDC flow; no other authentication path MUST exist, and no component
  outside Identity & Access MUST verify a credential.
  - **Applies to:** Identity & Access; `ARCHITECTURE.md` authentication model
  - **Verification:** Code review and test confirming credential verification exists in one component
    only
  - **References:** `REF-AUTH`, `REF-PASSKEY`, `REF-WEBAUTHN`, `REF-NIST-63B`
- **SEC-AUTHN-3** (PROVISIONAL) Passkey registration and authentication MUST verify the WebAuthn
  challenge, relying-party identifier and origin server-side against values the server issued, and
  MUST reject an assertion failing any of them. Attestation policy, authenticator requirements and
  credential lifecycle: `TO BE DECIDED`.
  - **Applies to:** Identity & Access passkey path
  - **Verification:** Negative tests with mismatched origin, replayed challenge and unknown credential
  - **References:** `REF-WEBAUTHN`, `REF-PASSKEY`, `REF-NIST-63B`
- **SEC-AUTHN-4** (PROVISIONAL) Passwords MUST be stored only as a salted hash from a memory-hard
  password-hashing function and MUST NOT be stored, logged or transmitted in reversible form.
  Algorithm, parameters and password composition/length policy: `TO BE DECIDED`.
  - **Applies to:** Identity & Access password path
  - **Verification:** Inspection of stored credential records; test asserting no plaintext credential
    appears in storage, logs or responses
  - **References:** `REF-AUTH`, `REF-NIST-63B`, `REF-ASVS-5`
- **SEC-AUTHN-5** (PROVISIONAL) The OIDC path MUST validate the issuer, audience, signature, nonce and
  expiry of every identity token against provider metadata, and MUST reject a token failing any check.
  Provider(s), flow and whether Squadar is also its own issuer: `UNKNOWN` / `TO BE DECIDED`.
  - **Applies to:** Identity & Access ↔ OIDC provider boundary
  - **Verification:** Negative tests for wrong issuer, wrong audience, bad signature, replayed nonce,
    expired token
  - **References:** `REF-AUTH`, `REF-ASVS-5`
- **SEC-AUTHN-6** (PROVISIONAL) Authentication failure responses MUST NOT reveal whether an account,
  passkey or email address exists, and MUST be uniform across those cases.
  - **Applies to:** Sign-in, account-access email and recovery endpoints
  - **Verification:** Comparison test of responses, status codes and timing for existing vs.
    non-existing identifiers
  - **References:** `REF-AUTH`, `REF-ERROR`
- **SEC-AUTHN-7** (PROVISIONAL) Credential-guessing resistance MUST be applied to password and
  account-access endpoints, keyed on at least the account identifier, and a rejected attempt MUST NOT
  be distinguishable from a throttled one to the caller. Thresholds, windows and lockout behavior:
  `TO BE DECIDED`.
  - **Applies to:** Identity & Access password and account-access endpoints
  - **Verification:** Test asserting repeated failures stop succeeding within the configured policy
  - **References:** `REF-AUTH`, `REF-NIST-63B`
- **SEC-AUTHN-8** (PROVISIONAL) Account-access and exam-invitation links sent by Outbound Notification
  MUST be single-use, time-bounded, unguessable, bound to the intended recipient account, and MUST NOT
  themselves confer a session beyond the action they authorize. Lifetime: `TO BE DECIDED`.
  - **Applies to:** Outbound Notification; Identity & Access; FR-5.5
  - **Verification:** Test that a link fails on second use, after expiry, and for a different account
  - **References:** `REF-AUTH`, `REF-ASVS-5`

### Session management

- **SEC-SESSION-1** (CONFIRMED) Session state MUST be carried in a JWT issued by Identity & Access;
  the API MUST verify its signature, issuer, audience and expiry on every request and MUST reject a
  token failing any check or presenting an unexpected algorithm.
  - **Applies to:** Client → REST API boundary; every authenticated request
  - **Verification:** Negative tests for `none`/mismatched algorithm, wrong issuer or audience,
    expired token and tampered payload
  - **References:** `REF-SESSION`, `REF-ASVS-5`, `REF-API-2023`
- **SEC-SESSION-2** (PROVISIONAL) The API MUST NOT trust any authorization-relevant claim in a JWT
  that it has not itself verified against the authoritative source for that attribute — role, assessor
  team assignments and the member a user corresponds to are resolved through Identity & Access and
  Roster, not accepted from a client-supplied token payload as the final word.
  - **Applies to:** Authorization context assembly; FR-1.2, FR-1.4, FR-1.5
  - **Verification:** Test that a validly signed token carrying a stale or elevated role does not grant
    the elevated operation
  - **References:** `REF-API-2023`, `REF-SESSION`
- **SEC-SESSION-3** (PROVISIONAL) A session MUST be revocable, and a revoked or role-changed session
  MUST stop authorizing protected operations without waiting for natural token expiry. Revocation
  mechanism, access-token lifetime, refresh model and idle/absolute timeouts: `TO BE DECIDED`.
  - **Applies to:** Identity & Access; FR-1.3 account deactivation and role change
  - **Verification:** Test that deactivating an account or changing its role blocks the next protected
    request on an already-issued token
  - **References:** `REF-SESSION`, `REF-ASVS-5`
- **SEC-SESSION-4** (PROVISIONAL) Session tokens MUST NOT be placed in URLs, query strings, browser
  `localStorage`/`sessionStorage`, or any client-side store readable by injected script; mobile tokens
  MUST use the platform's protected credential storage. Exact web transport (cookie vs. in-memory
  bearer) is `TO BE DECIDED`; whichever is chosen, `SEC-HTTP-3` applies if it carries ambient authority.
  - **Applies to:** Web Client, Mobile Client
  - **Verification:** Client review and automated check that no token value reaches web storage or a
    URL; inspection of mobile keystore usage
  - **References:** `REF-SESSION`, `REF-XSS`
- **SEC-SESSION-5** (PROVISIONAL) A new session identifier MUST be issued on authentication and on any
  privilege change, and the prior one MUST cease to be valid.
  - **Applies to:** Identity & Access
  - **Verification:** Test asserting the pre-authentication token is rejected after sign-in
  - **References:** `REF-SESSION`

### Authorization

- **SEC-AUTHZ-1** (CONFIRMED) The server-side application MUST verify that the authenticated actor is
  authorized for the requested operation and the specific target object before performing it, and MUST
  deny by default when no rule explicitly permits the combination.
  - **Applies to:** Every protected read and state-changing operation across Roster, Skill Catalog,
    Assessment, Identity & Access
  - **Verification:** Automated authorization matrix tests over permitted and prohibited
    actor/object/operation combinations, including object identifiers belonging to another team
  - **References:** `REF-ASVS-5`, `REF-API-2023`
- **SEC-AUTHZ-2** (CONFIRMED) Authorization decisions MUST evaluate the documented attributes — the
  actor's role, the teams an Assessor is assigned to, the team member the actor corresponds to, and
  shared-team membership — resolved server-side from the owning components, never from request body,
  header or path values supplied by the caller.
  - **Applies to:** ABAC decision point; FR-1.2, FR-1.4, FR-1.5
  - **Verification:** Test that supplying an attribute value in a request (role, team id, member id
    override) does not change the decision
  - **References:** `REF-API-2023`, `REF-ASVS-5`
- **SEC-AUTHZ-3** (CONFIRMED) A Team Member MUST be able to read only their own scores and exam
  results, plus the aggregated chart series for a team they belong to; any request for another
  individual's score detail MUST be denied.
  - **Applies to:** Assessment read endpoints; Chart Data Service; FR-1.4
  - **Verification:** Test per endpoint with a Team Member actor and another member's identifier,
    including chart, table, export and ranked-list routes
  - **References:** `REF-API-2023`, `REF-ASVS-5`
- **SEC-AUTHZ-4** (CONFIRMED) An Assessor MUST NOT be able to record, modify or delete a score for a
  team member outside the teams they are assigned to, on any code path including bulk operations.
  - **Applies to:** Assessment write endpoints; Bulk Import; FR-1.5
  - **Verification:** Test with an Assessor actor and out-of-team member identifiers, single and bulk
  - **References:** `REF-API-2023`
- **SEC-AUTHZ-5** (CONFIRMED) A Viewer MUST be denied every create, update and delete operation, and
  MUST NOT be granted a write path through import, export, exam submission or chart configuration
  persistence.
  - **Applies to:** All state-changing endpoints; FR-1.6
  - **Verification:** Automated sweep of every state-changing endpoint with a Viewer actor
  - **References:** `REF-ASVS-5`
- **SEC-AUTHZ-6** (CONFIRMED) Account creation, modification, deactivation and role assignment MUST be
  restricted to an Administrator, and an actor MUST NOT be able to change their own role.
  - **Applies to:** Identity & Access; FR-1.3
  - **Verification:** Privilege-escalation tests from each non-Administrator role, including self-role
    modification and mass-assignment of a role field on a profile update
  - **References:** `REF-API-2023`, `REF-ASVS-5`
- **SEC-AUTHZ-7** (CONFIRMED) A denial MUST report the refusal without disclosing the withheld data or
  confirming the existence of a record the actor may not see.
  - **Applies to:** All denied requests; FR-1.7
  - **Verification:** Test comparing denial responses for existing vs. non-existing target identifiers
  - **References:** `REF-ERROR`, `REF-API-2023`
- **SEC-AUTHZ-8** (CONFIRMED) A Team Member MUST be able to attempt only an exam assigned to them, and
  the API MUST reject a submission for an unassigned, withdrawn or already-completed attempt.
  - **Applies to:** Assessment exam endpoints; FR-5.6
  - **Verification:** Test submitting an unassigned exam identifier and resubmitting a completed
    attempt. Retake policy: `UNKNOWN`
  - **References:** `REF-API-2023`

### HTTP and API boundary

- **SEC-HTTP-1** (PROVISIONAL) All HTTP traffic crossing a trust boundary — clients to API, API to
  OIDC provider, API to mail provider, API to asset store — MUST use TLS, and the API MUST NOT accept
  plaintext HTTP for any product endpoint.
  - **Applies to:** All external HTTP interfaces
  - **Verification:** Connection test asserting plaintext requests are refused or redirected before any
    credential or data is accepted. TLS version floor and HSTS policy: `TO BE DECIDED`
  - **References:** `REF-REST`, `REF-ASVS-5`
- **SEC-HTTP-2** (PROVISIONAL) The API MUST resolve the endpoint's operation from the HTTP method and
  route only, MUST reject method or content-type values it does not implement for that route, and MUST
  parse a request body only in the content types it declares.
  - **Applies to:** REST API request handling
  - **Verification:** Tests sending unexpected methods, content types and method-override headers
  - **References:** `REF-REST`, `REF-API-2023`
- **SEC-HTTP-3** (PROVISIONAL, CONDITIONAL) If the web session is carried by a cookie or any other
  ambient credential the browser attaches automatically, the API MUST require a per-request CSRF
  defense on every state-changing request and MUST reject requests lacking it. If sessions are carried
  only as an explicitly attached bearer token, this rule does not apply. Transport choice:
  `TO BE DECIDED` (`SQ-5`).
  - **Applies to:** State-changing endpoints, Web Client
  - **Verification:** Cross-origin state-changing request test, run once the transport is decided
  - **References:** `REF-SESSION`, `REF-ASVS-5`
- **SEC-HTTP-4** (PROVISIONAL, CONDITIONAL) If either client is served from an origin other than the
  API's, CORS MUST allow only an explicit allow-list of client origins with no wildcard alongside
  credentials, and MUST NOT reflect an arbitrary `Origin` header. Deployment origins:
  `TO BE DECIDED`.
  - **Applies to:** REST API
  - **Verification:** Test that a non-allow-listed origin receives no permissive CORS response
  - **References:** `REF-REST`, `REF-API-2023`
- **SEC-HTTP-5** (PROVISIONAL) The API MUST apply request-rate and request-size limits to
  authentication, exam submission, bulk import, export and chart-dataset endpoints, and MUST refuse
  rather than degrade when a limit is exceeded. Concrete limits: `TO BE DECIDED`.
  - **Applies to:** REST API; NFR-9.1, NFR-9.2 at NFR-9.3 scale
  - **Verification:** Load test asserting a clean refusal with no partial write once limits are set
  - **References:** `REF-API-2023`, `REF-ASVS-5`
- **SEC-HTTP-6** (PROVISIONAL) List and chart endpoints MUST bound the number of members, skills and
  history records returned per request, enforcing the documented chart limits server-side and refusing
  an out-of-range selection with a stated reason rather than truncating silently.
  - **Applies to:** Chart Data Service, ranked lists, score tables; FR-7.6, FR-7.7, FR-6.3
  - **Verification:** Test requesting 13 axes and more than the supported member count directly against
    the API
  - **References:** `REF-API-2023`
- **SEC-HTTP-7** (PROVISIONAL) The Web Client MUST be served with a Content Security Policy and with
  response headers that prevent content-type sniffing and disallow framing by other origins. Exact
  directives and values: `TO BE DECIDED`.
  - **Applies to:** Web Client delivery
  - **Verification:** Header assertion test in the deployment pipeline once directives are decided
  - **References:** `REF-XSS`, `REF-ASVS-5`

### Input validation

- **SEC-INPUT-1** (CONFIRMED) The API MUST validate every request payload at the boundary where it
  enters, for both shape and business meaning, and MUST reject the request rather than coerce an
  invalid value.
  - **Applies to:** All REST endpoints (DR-1)
  - **Verification:** Schema and boundary tests per endpoint with malformed, over-long, wrong-typed and
    extra fields
  - **References:** `REF-INPUT`, `REF-PC-2024`
- **SEC-INPUT-2** (CONFIRMED) A skill score MUST be rejected unless it is an integer from 1 to 10
  inclusive, and a rejected score MUST NOT be recorded, partially recorded, or allowed to supersede an
  existing current score.
  - **Applies to:** Assessment score write path; FR-4.2, FR-4.3
  - **Verification:** Tests with 0, 11, 5.5, "5", null, NaN and absent values, asserting the prior
    current score is unchanged
  - **References:** `REF-INPUT`, `REF-ASVS-5`
- **SEC-INPUT-3** (CONFIRMED) The API MUST NOT accept a client-supplied value for any server-derived
  field — exam-derived score, scoring method, source assessor or exam, recorded date, audit fields —
  and MUST ignore or reject such fields when present.
  - **Applies to:** Assessment; FR-4.5, FR-5.7, FR-5.3, NFR-9.6
  - **Verification:** Mass-assignment tests submitting each derived field, asserting the server value
    prevails
  - **References:** `REF-API-2023`, `REF-ASVS-5`
- **SEC-INPUT-4** (CONFIRMED) Bulk import MUST validate each row through the same server-side rules as
  interactive entry, MUST report per-row rejections with reasons, and MUST NOT allow a row to bypass
  role, uniqueness or range validation.
  - **Applies to:** Bulk Import / Export; FR-8.1, FR-8.2, FR-3.3, FR-4.2
  - **Verification:** Import fixture mixing valid and invalid rows, asserting identical rejection
    reasons to the interactive path and no partially applied write
  - **References:** `REF-INPUT`, `REF-ASVS-5`
- **SEC-INPUT-5** (PROVISIONAL) Uploaded import files and any exam media MUST be constrained by
  declared size and type before parsing, MUST be parsed without evaluating embedded formulas, macros
  or references to external resources, and MUST NOT be stored under a caller-controlled filesystem
  path or name. Size and type limits: `TO BE DECIDED`.
  - **Applies to:** Bulk Import; Protected Asset Store writes
  - **Verification:** Tests with oversized files, mismatched declared types, formula-bearing cells and
    path-traversal file names
  - **References:** `REF-INPUT`, `REF-ASVS-5`
- **SEC-INPUT-6** (PROVISIONAL) Database access MUST use parameterized queries or an equivalent
  mechanism that separates statement structure from data; user-supplied values MUST NOT be
  concatenated into query text, including in sort, filter and pagination parameters. Sortable and
  filterable fields MUST come from a server-side allow-list.
  - **Applies to:** Domain components → Relational Data Store; FR-6.3 ranked lists
  - **Verification:** Code review plus tests submitting injection payloads in sort/filter parameters
  - **References:** `REF-PC-2024`, `REF-ASVS-5`

### Business-rule validation

- **SEC-BIZ-1** (CONFIRMED) Exam scoring — percentage correct and its conversion to a 1–10 band — MUST
  be computed server-side from the stored answer key, and a client-submitted score or percentage MUST
  be ignored.
  - **Applies to:** Assessment; FR-5.7, FR-5.8
  - **Verification:** Submission test including a forged score field, asserting the recorded score
    derives from the answers only
  - **References:** `REF-API-2023`, `REF-ASVS-5`
- **SEC-BIZ-2** (CONFIRMED) Recording a new score MUST preserve the superseded score in history and
  MUST leave exactly one current score per member per skill, enforced in the data store as well as in
  application logic.
  - **Applies to:** Assessment; Relational Data Store; FR-4.1, FR-4.6
  - **Verification:** Concurrent-write test asserting no duplicate current score and no lost history
  - **References:** `REF-ASVS-5`
- **SEC-BIZ-3** (CONFIRMED) A deactivated team member MUST be excluded from new assessments and a
  retired skill MUST NOT be offered for new assessments, enforced at the API regardless of what the
  client offers.
  - **Applies to:** Roster, Skill Catalog, Assessment; FR-2.3, FR-3.4
  - **Verification:** Direct API write attempts naming a deactivated member and a retired skill
  - **References:** `REF-ASVS-5`
- **SEC-BIZ-4** (CONFIRMED) An unassessed skill MUST be represented as absent and MUST NOT be
  defaulted to a numeric value anywhere in storage, the chart dataset or the score table.
  - **Applies to:** Assessment; Chart Data Service; FR-4.4, FR-7.9
  - **Verification:** Test asserting the absence marker survives from store to chart payload to table
  - **References:** `REF-ASVS-5`

### Output encoding and safe rendering

- **SEC-RENDER-1** (PROVISIONAL) The Web Client MUST render all server- and user-supplied text —
  member names, team names, skill names, exam question text, import error messages, chart axis and
  legend labels — through the framework's contextual escaping, and MUST NOT use raw HTML or DOM
  injection interfaces for it.
  - **Applies to:** Web Client (React); `DESIGN.md` chart, table and form surfaces
  - **Verification:** Lint rule banning raw-HTML injection props plus a rendering test with markup and
    script payloads in every displayed name field
  - **References:** `REF-XSS`, `REF-ASVS-5`
- **SEC-RENDER-2** (PROVISIONAL) Chart geometry and labels MUST be produced from structured data
  values, and no server-supplied string MUST be interpolated into SVG, canvas or style content in a way
  that could become executable markup.
  - **Applies to:** Web Client and Mobile Client radar chart; FR-7.1–FR-7.11
  - **Verification:** Test rendering a chart whose member and skill names contain markup, asserting
    literal display. Rendering library: `TO BE DECIDED` — evaluate it under `DEP-1`…`DEP-8`
  - **References:** `REF-XSS`
- **SEC-RENDER-3** (PROVISIONAL) Neither client MUST navigate to, embed or open a URL taken from
  server or user data without validating its scheme against an allow-list of safe schemes.
  - **Applies to:** Web Client, Mobile Client, including deep links and asset references
  - **Verification:** Test with `javascript:`, `data:` and app-scheme values in link-bearing fields
  - **References:** `REF-XSS`, `REF-ASVS-5`
- **SEC-RENDER-4** (CONFIRMED) An exam presented to a Team Member MUST be rendered from a payload that
  contains no answer-key data, in any field, comment, source map or cached response.
  - **Applies to:** Web Client, Mobile Client exam surfaces; NFR-9.7
  - **Verification:** Inspection of the network payload and client state during an exam attempt
  - **References:** `REF-API-2023`

### Data protection and privacy

- **SEC-DATA-1** (PROVISIONAL) Personal performance data — scores, history, exam attempts, audit
  entries — MUST be encrypted in transit across every boundary and encrypted at rest in the relational
  store and the asset store. Mechanisms and key management: `TO BE DECIDED`.
  - **Applies to:** Relational Data Store; Protected Asset Store
  - **Verification:** Infrastructure assertion in Terraform review and a deployed-configuration check
  - **References:** `REF-ASVS-5`, `REF-IAC`
- **SEC-DATA-2** (CONFIRMED) A team member's self-export MUST contain that member's own record only,
  and MUST NOT include another individual's scores, exam answer keys, or internal system identifiers
  beyond those needed to interpret the record.
  - **Applies to:** Bulk Import / Export; FR-8.3
  - **Verification:** Export test as a Team Member, asserting content is scoped to the caller
  - **References:** `REF-API-2023`
- **SEC-DATA-3** (CONFIRMED) After an Administrator performs deletion of a team member's personal data,
  that member and their scores MUST NOT appear in any chart, list, ranked view, export or search
  result. Whether deletion is erasure or irreversible anonymization, and its effect on audit entries,
  is `TO BE DECIDED` (`SQ-6`).
  - **Applies to:** Roster, Assessment, Chart Data Service; FR-8.4, NFR-9.6
  - **Verification:** Post-deletion sweep of every surface that can return member data, including
    cached and derived views
  - **References:** `REF-ASVS-5`
- **SEC-DATA-4** (PROVISIONAL) Each response MUST carry only the fields the caller's role and the
  screen require; score detail, exam content and account records MUST NOT be over-returned and filtered
  client-side.
  - **Applies to:** REST API responses; FR-1.4, FR-1.7
  - **Verification:** Response-shape tests per role against a documented per-role field list
  - **References:** `REF-API-2023`
- **SEC-DATA-5** (PROVISIONAL) Personal performance data MUST NOT be copied into non-production
  environments, test fixtures or seed data. The ten fake users required for testing (`UT-10.1`) MUST be
  synthetic and MUST NOT reproduce a real person's identity or scores.
  - **Applies to:** Test data, seeds, demo environments; UT-10.1
  - **Verification:** Review of seed fixtures; CI check that seed data is generated, not imported from
    a production source
  - **References:** `REF-ASVS-5`
- **SEC-DATA-6** (PROVISIONAL) Retention periods for score history, exam attempts, audit entries and
  authentication logs MUST be defined and enforced rather than left indefinite. Concrete periods and
  the data-subject rights the system must serve (access, erasure, portability, opt-out) are
  `TO BE DECIDED` pending `SQ-1`.
  - **Applies to:** Assessment; Identity & Access; logging
  - **Verification:** Not verifiable until the periods are decided
  - **References:** `REF-ASVS-5`, `REF-LOG`

### Secrets and keys

- **SEC-SECRET-1** (PROVISIONAL) Credentials, signing keys, OIDC client secrets, mail-provider
  credentials, database credentials and asset-store credentials MUST NOT appear in source control,
  client bundles, Terraform state committed to the repository, logs, error responses or build
  artifacts.
  - **Applies to:** All components and the deployment pipeline
  - **Verification:** Secret scanning in CI over source, bundles and IaC; manual review of client build
    output. Scanning product and secret store: `TO BE DECIDED`
  - **References:** `REF-SECRETS`, `REF-CICD`, `REF-IAC`
- **SEC-SECRET-2** (PROVISIONAL) The JWT signing key MUST be held only by Identity & Access and the
  verifying side, MUST be rotatable without redeploying application code, and rotation MUST NOT
  invalidate the ability to verify tokens issued moments before it. Algorithm and rotation cadence:
  `TO BE DECIDED`.
  - **Applies to:** Identity & Access; REST API
  - **Verification:** Rotation test asserting tokens issued before and after rotation behave as
    specified
  - **References:** `REF-SECRETS`, `REF-SESSION`
- **SEC-SECRET-3** (PROVISIONAL) Only configuration values safe to disclose publicly MUST be embedded
  in the Web Client bundle or the Mobile Client binary; both are distributable artifacts and MUST NOT
  be treated as a place to hold a secret.
  - **Applies to:** Web Client, Mobile Client builds
  - **Verification:** Automated scan of built bundles for secret-shaped values
  - **References:** `REF-SECRETS`

### Logging and error handling

- **SEC-LOG-1** (CONFIRMED) Every score create, change and delete MUST produce an audit entry naming
  the acting user, the affected member and skill, the method and the timestamp, retrievable only by an
  Administrator.
  - **Applies to:** Assessment; NFR-9.6
  - **Verification:** Test asserting an audit entry per score mutation and that non-Administrators
    cannot read the audit trail
  - **References:** `REF-LOG`, `REF-ASVS-5`
- **SEC-LOG-2** (PROVISIONAL) Security-relevant events — authentication success and failure, session
  revocation, authorization denial, role and account changes, bulk import runs, deletion requests —
  MUST be logged with actor, action, target and timestamp.
  - **Applies to:** Identity & Access; REST API; Roster
  - **Verification:** Test asserting a log entry per event class
  - **References:** `REF-LOG`, `REF-ASVS-5`
- **SEC-LOG-3** (PROVISIONAL) Logs MUST NOT contain credentials, session tokens, exam answer keys, or
  an individual's score values, and MUST record identifiers rather than personal content.
  - **Applies to:** All components; NFR-9.7
  - **Verification:** Log-scrubbing test exercising authentication, exam and scoring paths, asserting
    absence of those values
  - **References:** `REF-LOG`, `REF-SECRETS`
- **SEC-LOG-4** (PROVISIONAL) Audit and security log entries MUST NOT be modifiable or deletable
  through any product interface, and MUST be append-only from the application's perspective.
  - **Applies to:** Assessment audit store; NFR-9.6
  - **Verification:** Test attempting audit mutation through every role, asserting refusal
  - **References:** `REF-LOG`
- **SEC-ERR-1** (CONFIRMED) Error responses MUST state what is wrong in product terms without exposing
  stack traces, query text, internal identifiers, component names or dependency versions; diagnostics
  MUST be retained server-side and correlatable by an opaque reference.
  - **Applies to:** REST API; FR-1.7; `DESIGN.md` form-feedback behavior
  - **Verification:** Fault-injection test asserting responses carry no internal detail while the
    server-side record remains complete
  - **References:** `REF-ERROR`, `REF-API-2023`
- **SEC-ERR-2** (PROVISIONAL) An unhandled failure MUST NOT leave a partially applied change — a score
  recorded without history, an import half-applied, an exam scored without an audit entry.
  - **Applies to:** Assessment; Bulk Import; Relational Data Store
  - **Verification:** Failure-injection test mid-transaction asserting no partial state
  - **References:** `REF-ERROR`, `REF-ASVS-5`

### External integrations

- **SEC-EXT-1** (CONFIRMED) Each external system — OIDC provider, mail provider, asset store — MUST be
  reached only through the adapter owned by the component that needs it, and no vendor type, error or
  payload shape MUST cross out of that adapter.
  - **Applies to:** Identity & Access, Outbound Notification, Assessment; DR-6
  - **Verification:** Code review asserting vendor types do not appear in domain modules
  - **References:** `REF-ASVS-5`
- **SEC-EXT-2** (PROVISIONAL) Responses from external systems MUST be treated as untrusted input and
  validated before use; an external failure or malformed response MUST NOT cause the system to
  authorize an operation it would otherwise deny.
  - **Applies to:** OIDC token and metadata handling; mail delivery callbacks; asset-store responses
  - **Verification:** Tests injecting malformed, oversized and error responses from each adapter,
    asserting fail-closed behavior
  - **References:** `REF-API-2023`, `REF-INPUT`
- **SEC-EXT-3** (PROVISIONAL) Outbound email MUST carry the minimum content needed for the message and
  MUST NOT include a score, exam answer, or any credential in the message body.
  - **Applies to:** Outbound Notification; FR-5.5
  - **Verification:** Inspection of every message template against a permitted-field list
  - **References:** `REF-LOG`, `REF-SECRETS`
- **SEC-EXT-4** (PROVISIONAL) Server-side requests to external systems MUST target configured
  destinations only, and a URL derived from user or imported data MUST NOT be fetched by the server.
  - **Applies to:** REST API; Bulk Import; asset references
  - **Verification:** Test supplying internal and metadata-endpoint URLs in any field the server might
    dereference
  - **References:** `REF-ASVS-5`, `REF-API-2023`

### CI/CD, deployment and infrastructure as code

- **SEC-CICD-1** (PROVISIONAL) Application and infrastructure changes MUST reach any shared environment
  only through the pipeline, from reviewed source in version control; direct console or local
  deployment to a shared environment MUST NOT be a supported path.
  - **Applies to:** Deployment pipeline; Terraform-managed infrastructure. CI system: `UNKNOWN`
  - **Verification:** Review of branch protection and deployment credentials once the CI system is
    chosen
  - **References:** `REF-SSDF`, `REF-CICD`
- **SEC-CICD-2** (PROVISIONAL) Pipeline and deployment identities MUST hold the least privilege needed
  for their stage, MUST be distinct per environment, and MUST NOT be shared with developers or between
  production and non-production.
  - **Applies to:** CI/CD identities; Terraform execution identity
  - **Verification:** Review of identity-to-permission mapping in the Terraform configuration
  - **References:** `REF-CICD`, `REF-IAC`
- **SEC-CICD-3** (PROVISIONAL) Terraform configuration MUST be reviewed before apply, MUST be scanned
  for insecure infrastructure settings in CI, and MUST NOT provision a data store, asset store or
  network path that is publicly reachable unless that exposure is explicitly intended and documented.
  - **Applies to:** Terraform configuration; Relational Data Store, Protected Asset Store
  - **Verification:** IaC scanning in CI plus a documented review of every publicly reachable resource.
    Scanning tool and cloud provider: `TO BE DECIDED` / `UNKNOWN`
  - **References:** `REF-IAC`, `REF-CICD`
- **SEC-CICD-4** (PROVISIONAL) Terraform state MUST be stored in a protected remote backend with
  access control, versioning and encryption, and MUST NOT be committed to the repository — it may
  contain sensitive values. Backend: `TO BE DECIDED`.
  - **Applies to:** Terraform state
  - **Verification:** Repository check that no state file is tracked; backend configuration review
  - **References:** `REF-IAC`, `REF-SECRETS`
- **SEC-CICD-5** (PROVISIONAL) Build artifacts deployed to production MUST be traceable to the exact
  reviewed commit and dependency lockfile that produced them.
  - **Applies to:** Web Client, Mobile Client, REST API builds
  - **Verification:** Artifact metadata check in the pipeline
  - **References:** `REF-SSDF`, `REF-SUPPLY`
- **SEC-CICD-6** (PROVISIONAL) The security rules in this document MUST have automated checks that run
  in CI before merge wherever they are automatable, and a failing security check MUST block the merge.
  - **Applies to:** Pipeline; all rules above with an automated verification method
  - **Verification:** Pipeline configuration review
  - **References:** `REF-SSDF`, `REF-CICD`

## Requirement and Architecture Traceability

| Rule(s) | Requirements | Architecture component / boundary | Status |
| --- | --- | --- | --- |
| SEC-BOUND-1, SEC-BOUND-2 | FR-1.x, FR-4.2, FR-4.3, FR-5.7, FR-7.6, FR-7.7 | Client → REST API boundary; DR-1, DR-2 | CONFIRMED |
| SEC-BOUND-3, SEC-RENDER-4 | NFR-9.7, FR-1.7 | Assessment; REST API; DR-8 | CONFIRMED |
| SEC-BOUND-4 | — (no requirement names asset access) | API → Protected Asset Store; DR-9 | PROVISIONAL |
| SEC-AUTHN-1 | FR-1.1 | REST API; Identity & Access | CONFIRMED |
| SEC-AUTHN-2 | — (model from `ARCHITECTURE.md`) | Identity & Access | CONFIRMED |
| SEC-AUTHN-3, SEC-AUTHN-4, SEC-AUTHN-5 | — | Identity & Access | PARTIALLY DEFINED — parameters TO BE DECIDED |
| SEC-AUTHN-6, SEC-AUTHN-7 | FR-1.7 (non-disclosure) | Identity & Access | PROVISIONAL |
| SEC-AUTHN-8 | FR-5.5 | Outbound Notification; Identity & Access | PROVISIONAL |
| SEC-SESSION-1 | FR-1.1 | Client → REST API boundary | CONFIRMED |
| SEC-SESSION-2 | FR-1.2, FR-1.4, FR-1.5 | REST API; Identity & Access; Roster | CONFIRMED |
| SEC-SESSION-3 | FR-1.3 | Identity & Access | PARTIALLY DEFINED — mechanism TO BE DECIDED |
| SEC-SESSION-4, SEC-SESSION-5 | — | Web Client; Mobile Client; Identity & Access | PARTIALLY DEFINED — transport TO BE DECIDED (`SQ-5`) |
| SEC-AUTHZ-1, SEC-AUTHZ-2 | FR-1.2, FR-1.4, FR-1.5, FR-1.7 | REST API (sole enforcement point); Identity & Access | CONFIRMED |
| SEC-AUTHZ-3 | FR-1.4 | Assessment; Chart Data Service | CONFIRMED |
| SEC-AUTHZ-4 | FR-1.5 | Assessment; Bulk Import / Export; Roster | CONFIRMED |
| SEC-AUTHZ-5 | FR-1.6 | REST API | CONFIRMED |
| SEC-AUTHZ-6 | FR-1.3 | Identity & Access | CONFIRMED |
| SEC-AUTHZ-7 | FR-1.7 | REST API | CONFIRMED |
| SEC-AUTHZ-8 | FR-5.6 | Assessment | PARTIALLY DEFINED — retake policy UNKNOWN |
| SEC-HTTP-1, SEC-HTTP-2 | — | All external HTTP interfaces; REST API | PROVISIONAL |
| SEC-HTTP-3 | — | Web Client → REST API | TO BE DECIDED — conditional on session transport (`SQ-5`) |
| SEC-HTTP-4 | — | Web Client → REST API | TO BE DECIDED — deployment origins unknown |
| SEC-HTTP-5 | NFR-9.1, NFR-9.2, NFR-9.3 | REST API | PARTIALLY DEFINED — limits TO BE DECIDED |
| SEC-HTTP-6 | FR-7.6, FR-7.7, FR-6.3 | Chart Data Service; REST API | CONFIRMED |
| SEC-HTTP-7 | — | Web Client delivery | TO BE DECIDED — directives not chosen |
| SEC-INPUT-1 | All FR write paths | REST API; DR-1 | CONFIRMED |
| SEC-INPUT-2 | FR-4.2, FR-4.3 | Assessment; Relational Data Store | CONFIRMED |
| SEC-INPUT-3 | FR-4.5, FR-5.3, FR-5.7, NFR-9.6 | Assessment | CONFIRMED |
| SEC-INPUT-4 | FR-8.1, FR-8.2, FR-3.3 | Bulk Import / Export | CONFIRMED |
| SEC-INPUT-5 | FR-8.2 | Bulk Import / Export; Protected Asset Store | PARTIALLY DEFINED — formats and limits TO BE DECIDED |
| SEC-INPUT-6 | FR-6.3 | Domain components → Relational Data Store | PROVISIONAL |
| SEC-BIZ-1 | FR-5.7, FR-5.8 | Assessment | CONFIRMED |
| SEC-BIZ-2 | FR-4.1, FR-4.6 | Assessment; Relational Data Store | CONFIRMED |
| SEC-BIZ-3 | FR-2.3, FR-3.4 | Roster; Skill Catalog; Assessment | CONFIRMED |
| SEC-BIZ-4 | FR-4.4, FR-7.9 | Assessment; Chart Data Service | CONFIRMED |
| SEC-RENDER-1, SEC-RENDER-2, SEC-RENDER-3 | FR-7.1–FR-7.11, FR-6.2 | Web Client; Mobile Client (`DESIGN.md` surfaces) | PARTIALLY DEFINED — chart library TO BE DECIDED |
| SEC-DATA-1 | — | Relational Data Store; Protected Asset Store | PROVISIONAL |
| SEC-DATA-2 | FR-8.3 | Bulk Import / Export; Assessment | CONFIRMED |
| SEC-DATA-3 | FR-8.4, NFR-9.6 | Roster; Assessment; Chart Data Service | PARTIALLY DEFINED — erasure vs. anonymization TO BE DECIDED (`SQ-6`) |
| SEC-DATA-4 | FR-1.4, FR-1.7 | REST API | PROVISIONAL |
| SEC-DATA-5 | UT-10.1 | Test fixtures; all components | PROVISIONAL |
| SEC-DATA-6 | — | Assessment; Identity & Access; logging | TO BE DECIDED — pending `SQ-1` |
| SEC-SECRET-1, SEC-SECRET-2, SEC-SECRET-3 | — | All components; deployment pipeline; clients | PROVISIONAL |
| SEC-LOG-1 | NFR-9.6 | Assessment | CONFIRMED |
| SEC-LOG-2, SEC-LOG-3, SEC-LOG-4 | NFR-9.6, NFR-9.7 | Identity & Access; REST API; Assessment | PROVISIONAL |
| SEC-ERR-1 | FR-1.7 | REST API | CONFIRMED |
| SEC-ERR-2 | FR-4.6, FR-8.2 | Assessment; Bulk Import; Relational Data Store | PROVISIONAL |
| SEC-EXT-1 | — | Identity & Access; Outbound Notification; Assessment; DR-6 | CONFIRMED |
| SEC-EXT-2, SEC-EXT-4 | — | External adapters | PROVISIONAL |
| SEC-EXT-3 | FR-5.5 | Outbound Notification | PROVISIONAL |
| SEC-CICD-1 … SEC-CICD-6 | — | Deployment pipeline; Terraform-managed infrastructure | PARTIALLY DEFINED — CI system and provider UNKNOWN |
| DEP-1 … DEP-8 | — | All components | PROVISIONAL — no dependency exists yet |

## Dependency Security Rules

- **DEP-1** The project MUST NOT add a dependency when the standard library or a small amount of straightforward, non-security-sensitive first-party code is safer and sufficient. The project MUST NOT replace vetted cryptography, authentication, authorization, protocol parsing, output encoding, HTML sanitization, or other security-critical functionality with custom code merely to avoid a dependency.
- **DEP-2** The project SHOULD prefer zero new dependencies. Every new dependency MUST be justified in the pull request description, including its purpose and why existing code or platform functionality is insufficient.
- **DEP-3** A new dependency MUST show evidence of active maintenance through a stable release, security response, or substantive maintainer activity within the previous 12 months. A mature project with less frequent releases requires an explicit documented exception and evidence that security reports are still handled.
- **DEP-4** The project MUST use the latest stable release from the latest actively supported major version unless a documented compatibility constraint requires another actively supported major version. Deprecated, abandoned, end-of-life, or pre-release packages MUST NOT be introduced into production.
- **DEP-5** Before a dependency is added or updated, direct and transitive dependencies MUST be checked for known vulnerabilities. A dependency with a known unpatched vulnerability applicable to the intended use MUST NOT be introduced without explicit, time-bounded risk acceptance, documented compensating controls, and a remediation plan.
- **DEP-6** Dependency review MUST include the complete transitive dependency graph. A small direct dependency with a disproportionately large, opaque, abandoned, or unvetted transitive tree SHOULD be rejected.
- **DEP-7** Production builds MUST resolve dependencies to exact versions through a committed lockfile or equivalent ecosystem mechanism. Production and CI builds MUST use frozen or reproducible dependency resolution and MUST NOT resolve floating versions at build or deployment time.
- **DEP-8** When multiple suitable libraries exist, the project SHOULD prefer the library with the narrowest required scope, smallest dependency tree, active security response process, clear provenance, and established security track record.

These rules apply to the Node.js, React and React Native dependency trees and to Terraform providers
and modules. They are prospective: no dependency has been selected or assessed, because no
implementation exists. References: `REF-SUPPLY`, `REF-DEP`, `REF-SSDF`, `REF-CICD`.

## Prompt Placeholders To Resolve

- **`{{CODE_QUALITY_PROMPT}}` — RESOLVED.** No local code-quality prompt was found. Resolved to: low
  cyclomatic and cognitive complexity; small cohesive functions and modules; separated presentation,
  business-rule, persistence and integration concerns; explicit error handling and trust-boundary
  transitions; no duplicated security-sensitive logic; testability without hidden global state.
- **`{{API_SECURITY_PROMPT}}` — PARTIALLY RESOLVED.** `ARCHITECTURE.md` names a REST API, so
  `REF-API-2023` and `REF-REST` apply. API exposure (first-party-only contract vs. a separately
  consumable public API), versioning scheme and error format remain `TO BE DECIDED` (`SQ-4`).
- **`{{BACKEND_FRAMEWORK_PROMPT}}` — TO BE DECIDED.** The runtime is Node.js, but no backend framework
  or version is identified in any input document. No framework-specific guidance is selected; no
  framework is assumed.
- **`{{FRONTEND_FRAMEWORK_PROMPT}}` — TO BE DECIDED.** React.js (web) and React Native (mobile) are
  named, but no version is stated and no version-appropriate official security documentation or OWASP
  framework cheat sheet has been selected here. `REF-XSS` serves as the framework-neutral rendering
  baseline behind `SEC-RENDER-1`…`SEC-RENDER-3` but does not resolve this placeholder.
- **`{{AUTH_PROMPT}}` — PARTIALLY RESOLVED.** The mechanism set is identified: passkey/password + OIDC
  with JWT sessions. Selected: `REF-AUTH`, `REF-SESSION`, `REF-NIST-63B`, and — because passkeys are
  explicitly selected — `REF-PASSKEY` and `REF-WEBAUTHN`. Unresolved: OIDC provider and flow, password
  policy, MFA, passkey recovery, token lifetimes, revocation, assurance level (`SQ-3`, `SQ-5`, `SQ-7`).
- **`{{DEPLOYMENT_PROMPT}}` — PARTIALLY RESOLVED.** `REF-SSDF` and `REF-CICD` always apply;
  `REF-IAC` applies because infrastructure is Terraform-managed. Cloud provider, CI system, container
  or orchestrator use, and provider-specific guidance are `UNKNOWN` / `TO BE DECIDED` (`SQ-8`).

## Open Security Questions

- **SQ-1** The security notes state the education context is protected by GDPR and CCPA, while
  `REQUIREMENTS.md` states no special-category or regulated data is stored and names no jurisdiction.
  Which regimes actually apply, in which jurisdictions, and is Squadar a controller or a processor?
  This determines lawful basis, data-subject rights beyond FR-8.3/FR-8.4, breach-notification duties
  and the retention periods in `SEC-DATA-6`. Material conflict — unresolved.
- **SQ-2** The security notes specify ABAC, while `REQUIREMENTS.md` FR-1.2 specifies exactly one role
  per user. Is role one attribute within a broader ABAC policy (the reading taken here), or does ABAC
  replace the single-role model? What is the policy language, where does the decision point sit, and
  what is the source of record for each attribute?
- **SQ-3** What ASVS 5.0.0 verification level is the target, and what authenticator assurance level is
  required for each role — should an Administrator face a stronger requirement than a Viewer?
- **SQ-4** Is the REST API a first-party contract for the two clients only, or will it be exposed as a
  separately consumable API to third parties? This changes versioning, rate limiting, client
  registration and documentation exposure.
- **SQ-5** How is the JWT session carried on web — cookie (ambient authority, so `SEC-HTTP-3` CSRF
  defenses apply) or an explicitly attached bearer token? What are the access-token lifetime, refresh
  model, revocation mechanism and idle/absolute timeouts, and how do they differ on mobile?
- **SQ-6** Is FR-8.4 deletion an irreversible erasure or an anonymization, and what happens to the
  NFR-9.6 audit entries that name the deleted member? The two obligations pull against each other.
- **SQ-7** What is the account-recovery path when a user loses their passkey, and how is it prevented
  from becoming a weaker parallel authentication route? Is password authentication a permanent peer of
  passkeys or a migration path, and is MFA required alongside it?
- **SQ-8** Which cloud provider, CI system and runtime topology will Terraform provision, and where do
  the Protected Asset Store and the relational database live? Provider-specific controls, the asset
  access-grant mechanism, and the secret store cannot be specified until this is answered.
- **SQ-9** What are the abuse and resource limits for exam submission, chart dataset requests and bulk
  import at the stated enterprise scale, and should bulk import run as background work with its own
  authorization and audit trail?
- **SQ-10** Is the OIDC provider trusted to assert role or group membership, or is role always assigned
  locally by an Administrator (FR-1.3)? If the provider asserts it, provider compromise becomes a
  privilege-escalation path.
- **SQ-11** Are exam attempts subject to proctoring, timing or retake constraints? Without a stated
  policy, `SEC-AUTHZ-8` cannot fully specify what a valid attempt is, and answer-key confidentiality
  (NFR-9.7) does not by itself prevent collusion between team members.
- **SQ-12** What is the incident-response path — who is notified on a suspected exposure of personal
  performance data or an answer-key leak, and within what time?
