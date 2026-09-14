# 08 — Threat Model Diagrams

Generated from `07-consolidated.cdx.json`. Five diagram types, each in ASCII, Mermaid and Graphviz DOT.

**Note on provenance:** `squadar` contains no architecture diagram. Every diagram here is synthesized
from the prose in `ARCHITECTURE.md` and the consolidated model — no component, flow or boundary is
invented. Dashed borders are trust boundaries; solid borders are component groupings.

---

## 1. System Context Diagram

### ASCII

```
                                SQUADAR — SYSTEM CONTEXT
    Legend:  [ ] actor/system   ( ) system under assessment   ==> trust boundary crossing

      +----------------+          +----------------+          +----------------+
      | Administrator  |          |    Assessor    |          |  Team Member   |
      | accounts,roles |          | scores in own  |          | exams, own     |
      | catalog,import |          | assigned teams |          | record, self   |
      +--------+-------+          +--------+-------+          +--------+-------+
               |                           |                           |
               |  HTTPS / JWT              |  HTTPS / JWT              |  HTTPS / JWT
               |  personal perf. data      |  personal perf. data      |  exam + score data
               v                           v                           v
      ===================== TB-1  CLIENT -> REST API  =============================
      |                                                                           |
      |            (            S Q U A D A R                     )               |
      |            (  assess skills 1-10, rank, shared radar chart )               |
      |                                                                           |
      ===========================================================================
               ^                    |                    |                 |
               |  HTTPS / JWT       | TB-2               | TB-5            | TB-3
               |  read-only         | OIDC id tokens     | email           | asset grants
      +--------+-------+   +--------v-------+   +--------v-------+  +------v---------+
      |     Viewer     |   | OIDC Identity  |   | Transactional  |  | Protected      |
      | charts, tables |   |   Provider     |   | Mail Provider  |  | Asset Store    |
      +----------------+   | (UNKNOWN)      |   | (TBD)          |  | exam media     |
                           +----------------+   +----------------+  +----------------+
                             ^ T-02 (SQ-10)       ^ T-10, T-30        ^ T-09

    No unauthenticated product surface exists (FR-1.1). Every edge above crosses a trust boundary.
```

### Mermaid

```mermaid
graph TB
    admin["Administrator<br/>accounts, roles, catalog, import"]
    assessor["Assessor<br/>scores for assigned teams"]
    member["Team Member<br/>exams, own record, self-assessment"]
    viewer["Viewer<br/>read-only charts and tables"]

    subgraph TB1["TB-1 — Client to REST API (sole enforcement boundary)"]
        squadar(("Squadar<br/>assess skills 1-10, rank,<br/>shared radar chart"))
    end

    oidc["OIDC Identity Provider<br/>(provider UNKNOWN)"]
    mail["Transactional Mail Provider<br/>(provider TBD)"]
    blob["Protected Asset Store<br/>exam media"]

    admin -->|"HTTPS / JWT — personal performance data"| squadar
    assessor -->|"HTTPS / JWT — personal performance data"| squadar
    member -->|"HTTPS / JWT — exam and score data"| squadar
    viewer -->|"HTTPS / JWT — read-only"| squadar

    squadar <-->|"TB-2 — OIDC id tokens"| oidc
    squadar -->|"TB-5 — invitation and access email"| mail
    squadar -->|"TB-3 — per-asset, time-bounded grant"| blob

    style TB1 stroke-dasharray: 6 4
```

### Graphviz DOT

```dot
digraph squadar_context {
  rankdir=TB; fontname="Helvetica"; node [fontname="Helvetica", fontsize=10];
  node [shape=box, style=rounded];

  admin    [label="Administrator"];
  assessor [label="Assessor"];
  member   [label="Team Member"];
  viewer   [label="Viewer"];
  oidc     [label="OIDC Identity Provider\n(UNKNOWN)", style="rounded,dashed"];
  mail     [label="Mail Provider\n(TBD)", style="rounded,dashed"];
  blob     [label="Protected Asset Store", shape=cylinder, style=solid];

  subgraph cluster_tb1 {
    label="TB-1  Client -> REST API"; style=dashed; color=firebrick;
    squadar [label="SQUADAR", shape=ellipse, style=bold];
  }

  admin    -> squadar [label="HTTPS/JWT  admin ops"];
  assessor -> squadar [label="HTTPS/JWT  scores"];
  member   -> squadar [label="HTTPS/JWT  exams, own record"];
  viewer   -> squadar [label="HTTPS/JWT  read-only"];
  squadar  -> oidc    [label="TB-2  id tokens", dir=both, color=firebrick];
  squadar  -> mail    [label="TB-5  email", color=firebrick];
  squadar  -> blob    [label="TB-3  scoped grant", color=firebrick];
}
```

---

## 2. Container / Component Diagram

### ASCII

```
                       SQUADAR — COMPONENTS      ( = = = trust boundary,  --- ownership )

  +-- UNTRUSTED CLIENT ZONE ------------------------------------------------------------+
  |  +---------------------------+          +---------------------------+               |
  |  | Web Client   React.js     |          | Mobile Client  React Nat. |               |
  |  | no durable data, DR-1     |          | same surface, same trust  |               |
  |  +-------------+-------------+          +-------------+-------------+               |
  +----------------|----------------------------------------|----------------------------+
                   |                 REST / HTTPS / JWT      |
  === TB-1 ========v========================================v==============================
  |  +----------------------------------------------------------------------------+      |
  |  |  REST API   (Node.js, framework TBD)                                        |      |
  |  |  sole enforcement point: authn, ABAC authz, validation, limits, error shape  |      |
  |  |  +---------------------------------------------------------------------+    |      |
  |  |  |  Chart Data Service  - one dataset for chart AND table (DR-7)        |    |      |
  |  |  +---------------------------------------------------------------------+    |      |
  |  +---+-------------+--------------+---------------+------------------+---------+      |
  |      |             |              |               |                  |                |
  |  +---v-------+ +---v--------+ +---v----------+ +--v-------------+ +--v-------------+  |
  |  | Identity  | |  Roster    | | Skill        | |  Assessment    | | Bulk Import /  |  |
  |  | & Access  | | members,   | | Catalog      | |  scores,history| | Export         |  |
  |  | users,    | | teams,     | | skills       | |  exams, ANSWER | | rows via owner |  |
  |  | roles,    | | membership | |              | |  KEYS, attempts| |                |  |
  |  | sessions  | |            | |              | |  audit entries | |                |  |
  |  +---+-------+ +---+--------+ +---+----------+ +--+-------------+ +--+-------------+  |
  |      |             |              |               |                  |                |
  |      |             +--------------+---------------+------------------+                |
  |      |                            | TB-4                                              |
  |      |                  +---------v----------+      +-------------------------+       |
  |      |                  | Relational Store   |      | Outbound Notification   |       |
  |      |                  | 3NF, product TBD   |      | delivery edge only      |       |
  |      |                  +--------------------+      +-----------+-------------+       |
  ====== |======================================================== | ====== TB-3 ========
         | TB-2                                              TB-5  |        |
  +------v----------+                                   +---------v-----+  +v--------------+
  | OIDC Provider   |                                   | Mail Provider |  | Protected     |
  | (UNKNOWN)       |                                   | (TBD)         |  | Asset Store   |
  +-----------------+                                   +---------------+  +---------------+

  Dependency direction is acyclic: clients -> API -> domain components -> persistence/edges (DR-5).
  No client reaches a store or a domain component directly (DR-2).
```

### Mermaid

```mermaid
graph TB
    subgraph clients["Untrusted client zone — public code (DR-1)"]
        web["Web Client<br/>React.js"]
        mob["Mobile Client<br/>React Native"]
    end

    subgraph server["TB-1 — server side, sole enforcement point"]
        api["REST API — Node.js<br/>authn, ABAC authz, validation, limits"]
        chart["Chart Data Service<br/>one dataset for chart and table (DR-7)"]
        iam["Identity & Access<br/>users, roles, sessions"]
        roster["Roster<br/>members, teams, membership"]
        cat["Skill Catalog<br/>skills"]
        assess["Assessment<br/>scores, history, exams,<br/>ANSWER KEYS, attempts, audit"]
        imp["Bulk Import / Export"]
        notify["Outbound Notification"]
    end

    db[("Relational Data Store<br/>3NF, product TBD")]
    blob[("Protected Asset Store<br/>exam media")]
    oidc["OIDC Provider (UNKNOWN)"]
    mail["Mail Provider (TBD)"]

    web -->|REST/HTTPS/JWT| api
    mob -->|REST/HTTPS/JWT| api
    api --> chart
    api --> iam
    api --> roster
    api --> cat
    api --> assess
    api --> imp
    chart -.reads.-> assess
    chart -.reads.-> roster
    chart -.reads.-> cat
    roster -. deletion event .-> assess
    assess --> notify
    iam --> notify
    iam --> db
    roster --> db
    cat --> db
    assess --> db
    assess --> blob
    iam <-->|TB-2| oidc
    notify -->|TB-5| mail

    style server stroke-dasharray: 6 4
```

### Graphviz DOT

```dot
digraph squadar_components {
  rankdir=TB; node [fontname="Helvetica", fontsize=10, shape=box, style=rounded];

  subgraph cluster_client {
    label="Untrusted client zone (DR-1)"; style=dashed; color=gray50;
    web [label="Web Client\nReact.js"]; mob [label="Mobile Client\nReact Native"];
  }
  subgraph cluster_server {
    label="TB-1  server side — sole enforcement point"; style=dashed; color=firebrick;
    api    [label="REST API (Node.js)", style="rounded,bold"];
    chart  [label="Chart Data Service"];
    iam    [label="Identity & Access"];
    roster [label="Roster"];
    cat    [label="Skill Catalog"];
    assess [label="Assessment\nscores, exams, ANSWER KEYS, audit", style="rounded,bold"];
    imp    [label="Bulk Import / Export"];
    notify [label="Outbound Notification"];
  }
  db   [label="Relational Data Store", shape=cylinder, style=solid];
  blob [label="Protected Asset Store", shape=cylinder, style=solid];
  oidc [label="OIDC Provider", style="rounded,dashed"];
  mail [label="Mail Provider", style="rounded,dashed"];

  web -> api; mob -> api;
  api -> {chart iam roster cat assess imp};
  chart -> {assess roster cat} [style=dotted, label="read"];
  roster -> assess [style=dotted, label="deletion event (DR-5)"];
  {assess iam} -> notify;
  {iam roster cat assess} -> db [color=firebrick, label="TB-4"];
  assess -> blob [color=firebrick, label="TB-3"];
  iam -> oidc [dir=both, color=firebrick, label="TB-2"];
  notify -> mail [color=firebrick, label="TB-5"];
}
```

---

## 3. Data Flow Diagram

### ASCII

```
  SQUADAR — DATA FLOW      Sensitivity:  [S] secret  [P] personal performance  [C] confidential system

  ACTOR            TB-1              PROCESSING                    TB-4 / TB-3        STORAGE
  ------------------------------------------------------------------------------------------------
  Team Member  ==> sign in       --> Identity & Access  ========>  credentials [S]    Relational
               [S] credentials       verify passkey/pw/OIDC        session key [S]    Store
                                     issue JWT [S]                                    (enc. at rest
                                     (TB-2 to OIDC provider)                           SPECIFIED,
                                                                                       not built)
  Team Member  ==> select members --> Chart Data Service <========  current scores [P]
               and skills            one dataset -> chart          member records [P]
               <== chart + table      AND table (DR-7)      [P]
                   *** the same payload carries every selected member's scores — see T-04 ***

  Team Member  ==> open exam      --> Assessment          <========  questions [C]
               <== questions       ** answer keys excluded IN Assessment (DR-8) **     answer keys [C]
                   WITHOUT keys [C]                                                    *** never
               ==> answers [P]    --> score server-side from key ==> attempt [P]        outbound ***
               <== 1-10 band [P]      write score + history + audit  score history [P]
                                      in ONE transaction (T-21)      audit entry [P]

  Assessor     ==> score 1-10 [P] --> Assessment: validate range,  ==> supersede current,
                                      authorize team scope (T-08)      retain history [P]

  Administrator==> import file    --> Bulk Import: per-ROW validation and authorization
               <== per-row reject      then write THROUGH Roster / Skill Catalog  ==> members [P]

  Administrator==> delete member  --> Roster --(event)--> Assessment: remove from every
                                      chart, list, export, cache ... and the audit trail? (T-25)

  Any actor    <== exam media     <-- API issues scoped, time-bounded grant == TB-3 ==> media [C]
                                      possession of a reference is NOT entitlement (DR-9)

  System       ==> invitation     == TB-5 ==> Mail Provider   minimum content, never a score (T-30)
```

### Mermaid

```mermaid
flowchart LR
    member(["Team Member"])
    assessor(["Assessor"])
    admin(["Administrator"])

    subgraph api["TB-1 — REST API boundary"]
        authn["Authenticate<br/>passkey / password / OIDC"]
        chartsvc["Assemble chart dataset<br/>limits enforced server-side"]
        examsvc["Serve exam without keys<br/>score from stored key"]
        scoresvc["Validate and record score<br/>supersede + history + audit"]
        impsvc["Validate import per row"]
    end

    db[("Relational Store<br/>credentials S · scores P · answer keys C · audit P")]
    blob[("Asset Store<br/>exam media C")]
    mail(["Mail Provider"])

    member -->|"credentials S"| authn
    authn -->|"JWT S"| member
    authn --> db

    member -->|"member + skill selection"| chartsvc
    chartsvc -->|"chart + table, scores P — see T-04"| member
    chartsvc --> db

    member -->|"open assigned exam"| examsvc
    examsvc -->|"questions WITHOUT keys C"| member
    member -->|"answers P"| examsvc
    examsvc -->|"1-10 band P"| member
    examsvc --> db

    assessor -->|"score 1-10 P"| scoresvc
    scoresvc --> db
    admin -->|"delimited file"| impsvc
    impsvc -->|"per-row rejections"| admin
    impsvc --> db

    examsvc -->|"scoped, time-bounded grant"| blob
    examsvc -->|"invitation, no score content"| mail

    style api stroke-dasharray: 6 4
```

### Graphviz DOT

```dot
digraph squadar_dfd {
  rankdir=LR; node [fontname="Helvetica", fontsize=9];
  node [shape=box, style=rounded];
  edge [fontsize=8];

  member [shape=oval, label="Team Member"]; assessor [shape=oval, label="Assessor"];
  admin  [shape=oval, label="Administrator"];

  subgraph cluster_api {
    label="TB-1  REST API boundary"; style=dashed; color=firebrick;
    authn [label="Authenticate"]; chartsvc [label="Chart dataset"];
    examsvc [label="Exam serve + score"]; scoresvc [label="Record score"];
    impsvc [label="Bulk import"];
  }
  db   [shape=cylinder, label="Relational Store"];
  blob [shape=cylinder, label="Asset Store"];
  mail [shape=oval, style=dashed, label="Mail Provider"];

  member -> authn    [label="credentials [S]", color=red];
  authn  -> member   [label="JWT [S]", color=red];
  member -> chartsvc [label="selection"];
  chartsvc -> member [label="scores [P]  T-04", color=orange];
  member -> examsvc  [label="answers [P]"];
  examsvc -> member  [label="questions, NO keys [C]", color=orange];
  assessor -> scoresvc [label="score 1-10 [P]"];
  admin -> impsvc    [label="delimited file"];
  {authn chartsvc examsvc scoresvc impsvc} -> db [color=firebrick, label="TB-4"];
  examsvc -> blob [color=firebrick, label="TB-3 scoped grant"];
  examsvc -> mail [color=firebrick, label="TB-5 no score content"];
}
```

---

## 4. Threat-Annotated Architecture

### ASCII

```
  SQUADAR — THREAT-ANNOTATED ARCHITECTURE
  Severity markers:  !!! Critical   !! High   ! Medium   ~ Low

  +-- UNTRUSTED CLIENTS -------------------------------------------------------------------+
  |  Web Client  !! T-12 stored XSS via chart labels        Mobile Client  ! T-12           |
  |              ! T-16 CSRF (if cookie session)                                            |
  +--------------------------------|--------------------------------------------------------+
  === TB-1 =======================v========================================================
  |  REST API                                                                              |
  |   !!! T-01 object-level authorization on every id-bearing read                         |
  |   !!! T-02 privilege escalation: mass assignment / function-level / OIDC role claim    |
  |    !! T-05 JWT algorithm and claim verification                                        |
  |    !! T-06 stale authority: revocation and role change                                 |
  |     ! T-18 account enumeration    ! T-19 resource exhaustion    ! T-23 logging leaks    |
  |  +----------------------------------------------------------------------------+        |
  |  | Chart Data Service   !! T-04 peer score exposure (FR-1.4 vs FR-7.3)         |        |
  |  |                       ! T-19 cross-product query amplification              |        |
  |  +----------------------------------------------------------------------------+        |
  |  +-------------+ +-----------+ +---------+ +-------------------------+ +--------------+ |
  |  | Identity &  | | Roster    | | Skill   | | Assessment              | | Bulk Import  | |
  |  | Access      | |           | | Catalog | | !! T-03 answer keys     | | !! T-08 out- | |
  |  | !! T-10 rec-| | ! T-25    | |         | | !! T-07 score forgery   | |    of-team   | |
  |  |    overy /  | |   deletion| |         | | !! T-08 assessor scope  | |  ! T-24 CSV  | |
  |  |    links    | |   residue | |         | |  ! T-14 self-inflation  | |  ! T-27 SSRF | |
  |  | ! T-17 brute| |           | |         | |  ! T-15 collusion       | |  ! T-19 size | |
  |  |   force     | |           | |         | |  ! T-20 concurrency     | |              | |
  |  |             | |           | |         | |  ! T-21 partial write   | |              | |
  |  |             | |           | |         | |  ! T-22 audit / admin   | |              | |
  |  +------+------+ +-----+-----+ +----+----+ +-----------+-------------+ +------+-------+ |
  ========= | ============ | =========== | ================= | ================= | =========
       TB-2 |         TB-4 v             v                   | TB-3              | TB-5
  +---------v------+  +----------------------------+  +-------v---------+ +------v---------+
  | OIDC Provider  |  | Relational Store           |  | Asset Store     | | Mail Provider  |
  | !!! T-02 role  |  | !! T-11 SQLi sort/filter   |  | !! T-09 ref as  | | ~ T-30 content |
  |     claim SQ-10|  |  ! T-26 retention undefined|  |    entitlement  | |                |
  +----------------+  |  ~ T-31 fixture data       |  +-----------------+ +----------------+
                      +----------------------------+

  DEVELOPMENT BOUNDARY TB-7 (not a product boundary)
   !! T-13 Terraform provisions a public store    ! T-28 supply chain    ! T-29 secrets/state
   ~ T-32 unenforced test gate, specs as agent instruction channel

  LEGEND  T-01 BOLA | T-02 priv-esc | T-03 answer keys | T-04 peer scores | T-05 JWT | T-06 stale
  authority | T-07 score forgery | T-08 assessor scope | T-09 asset refs | T-10 recovery/links
  T-11 SQLi | T-12 XSS | T-13 public infra | T-14 self-inflation | T-15 collusion | T-16 CSRF
  T-17 brute force | T-18 enumeration | T-19 exhaustion | T-20 concurrency | T-21 partial write
  T-22 audit/admin | T-23 log leakage | T-24 CSV injection | T-25 deletion residue | T-26 retention
  T-27 SSRF | T-28 supply chain | T-29 secrets | T-30 email | T-31 fixtures | T-32 dev boundary
```

### Mermaid

```mermaid
graph TB
    subgraph clients["Untrusted clients"]
        web["Web Client<br/>T-12 XSS · T-16 CSRF"]
        mob["Mobile Client<br/>T-12"]
    end

    subgraph server["TB-1 — server side"]
        api["REST API<br/>T-01 BOLA · T-02 priv-esc<br/>T-05 JWT · T-06 stale authority<br/>T-18 · T-19 · T-23"]
        chart["Chart Data Service<br/>T-04 peer scores · T-19"]
        iam["Identity & Access<br/>T-10 recovery · T-17 brute force"]
        roster["Roster<br/>T-25 deletion residue"]
        assess["Assessment<br/>T-03 answer keys · T-07 forgery<br/>T-08 scope · T-14 · T-15<br/>T-20 · T-21 · T-22"]
        imp["Bulk Import<br/>T-08 · T-24 · T-27"]
    end

    db[("Relational Store<br/>T-11 SQLi · T-26 retention")]
    blob[("Asset Store<br/>T-09 reference as entitlement")]
    oidc["OIDC Provider<br/>T-02 role claim (SQ-10)"]
    mail["Mail Provider<br/>T-30"]

    subgraph dev["TB-7 — development boundary"]
        iac["Terraform / CI<br/>T-13 public infra · T-28 supply chain<br/>T-29 secrets · T-32 test gate"]
    end

    web --> api
    mob --> api
    api --> chart & iam & roster & assess & imp
    iam --> oidc
    assess --> blob
    assess --> mail
    chart & iam & roster & assess & imp --> db

    classDef crit fill:#7f1d1d,color:#fff,stroke:#450a0a;
    classDef high fill:#b45309,color:#fff,stroke:#78350f;
    classDef med  fill:#a16207,color:#fff,stroke:#713f12;
    class api crit
    class assess,chart,iam,blob,oidc,db high
    class imp,roster,web,mob,mail,iac med
    style server stroke-dasharray: 6 4
    style dev stroke-dasharray: 2 4
```

### Graphviz DOT

```dot
digraph squadar_threats {
  rankdir=TB; node [fontname="Helvetica", fontsize=9, shape=box, style="rounded,filled", fontcolor=white];

  subgraph cluster_server {
    label="TB-1  server side"; style=dashed; color=firebrick; fontcolor=black;
    api    [label="REST API\n!!! T-01  !!! T-02\n!! T-05  !! T-06\n! T-18 T-19 T-23", fillcolor="#7f1d1d"];
    chart  [label="Chart Data Service\n!! T-04  ! T-19", fillcolor="#b45309"];
    assess [label="Assessment\n!! T-03 T-07 T-08\n! T-14 T-15 T-20 T-21 T-22", fillcolor="#b45309"];
    iam    [label="Identity & Access\n!! T-10  ! T-17", fillcolor="#b45309"];
    roster [label="Roster\n! T-25", fillcolor="#a16207"];
    imp    [label="Bulk Import\n!! T-08  ! T-24 T-27", fillcolor="#a16207"];
  }
  subgraph cluster_client {
    label="Untrusted clients"; style=dashed; color=gray50; fontcolor=black;
    web [label="Web Client\n!! T-12  ! T-16", fillcolor="#a16207"];
    mob [label="Mobile Client\n! T-12", fillcolor="#a16207"];
  }
  subgraph cluster_dev {
    label="TB-7  development boundary"; style=dotted; color=gray50; fontcolor=black;
    iac [label="Terraform / CI\n!! T-13  ! T-28 T-29  ~ T-32", fillcolor="#a16207"];
  }
  db   [label="Relational Store\n!! T-11  ! T-26  ~ T-31", shape=cylinder, fillcolor="#b45309"];
  blob [label="Asset Store\n!! T-09", shape=cylinder, fillcolor="#b45309"];
  oidc [label="OIDC Provider\n!!! T-02 role claim", fillcolor="#7f1d1d"];
  mail [label="Mail Provider\n~ T-30", fillcolor="#4b5563"];

  {web mob} -> api;
  api -> {chart iam roster assess imp};
  iam -> oidc [color=firebrick]; assess -> blob [color=firebrick]; assess -> mail [color=firebrick];
  {chart iam roster assess imp} -> db [color=firebrick];
}
```

---

## 5. Attack Surface Map

### ASCII

```
  SQUADAR — ATTACK SURFACE       [*] = carries a Critical or High threat
  Every entry point requires authentication (FR-1.1). There is no unauthenticated product surface.

  ENTRY POINT                    AUTHN        AUTHORIZATION                   THREATS
  ---------------------------------------------------------------------------------------------
 [*] Sign in (passkey/password)  boundary     none (is the boundary)          T-05 T-10 T-17 T-18
 [*] OIDC callback               boundary     issuer/audience/nonce           T-02 T-05
 [*] Account-access email link   link token   single-use, recipient-bound     T-10 T-18
 [*] Exam invitation link        link token   single-use, recipient-bound     T-10 T-30
 [*] Chart dataset               required     role + shared-team membership   T-01 T-04 T-12 T-19
 [*] Score table / ranked list   required     role + team scope               T-01 T-11 T-19
 [*] Score detail read           required     self, or assessor team scope    T-01
 [*] Score write (assessor)      required     Assessor: assigned teams only   T-08 T-20 T-21 T-22
  .  Score write (self)          required     self only                       T-14 T-20
 [*] Exam fetch (questions)      required     assigned attempt; NO keys       T-03 T-15
 [*] Exam submit                 required     assigned, uncompleted attempt   T-07 T-15 T-20 T-21
 [*] Exam definition CRUD        required     Administrator (holds keys)      T-02 T-03
  .  Exam assignment             required     Assessor or Administrator       T-08
  .  Skill catalog CRUD          required     Administrator                   T-12 T-02
  .  Team member CRUD            required     Administrator                   T-02 T-12
  .  Team create / save / reopen required     role-dependent                  T-01 T-25
 [*] Account and role CRUD       required     Administrator only              T-02 T-06 T-22
 [*] Bulk import (file upload)   required     Administrator                   T-08 T-19 T-24 T-27
 [*] Self export                 required     self only                       T-01 T-24
  .  Personal-data deletion      required     Administrator                   T-25 T-22
  .  Audit trail read            required     Administrator only              T-22
 [*] Protected asset read        required     live per-asset grant            T-09
  ---------------------------------------------------------------------------------------------
  22 entry points. 15 carry a Critical or High threat. 0 are unauthenticated by design.

  HIGHEST-VALUE TARGETS
    1. Account and role CRUD  -> Administrator authority -> everything else
    2. Exam fetch / definition -> answer keys -> silent, permanent assessment integrity loss
    3. Chart dataset          -> the whole organization's personal performance data in one payload
```

### Mermaid

```mermaid
graph LR
    subgraph auth["Authentication surface"]
        s1["Sign in ⚠"]
        s2["OIDC callback ⚠"]
        s3["Account-access link ⚠"]
        s4["Exam invitation link ⚠"]
    end
    subgraph read["Read surface"]
        r1["Chart dataset ⚠"]
        r2["Score table / ranked list ⚠"]
        r3["Score detail ⚠"]
        r4["Self export ⚠"]
        r5["Audit trail read"]
        r6["Protected asset read ⚠"]
        r7["Exam fetch ⚠"]
    end
    subgraph write["Write surface"]
        w1["Score write — assessor ⚠"]
        w2["Score write — self"]
        w3["Exam submit ⚠"]
        w4["Exam definition CRUD ⚠"]
        w5["Exam assignment"]
        w6["Skill catalog CRUD"]
        w7["Team member CRUD"]
        w8["Team save / reopen"]
        w9["Account and role CRUD ⚠"]
        w10["Bulk import ⚠"]
        w11["Personal-data deletion"]
    end

    classDef hot fill:#7f1d1d,color:#fff;
    class w9,w4,r7,r1 hot
```

### Graphviz DOT

```dot
digraph squadar_surface {
  rankdir=LR; node [fontname="Helvetica", fontsize=9, shape=box, style="rounded,filled", fillcolor="#e5e7eb"];

  subgraph cluster_auth  { label="Authentication surface"; style=rounded;
    signin [label="Sign in\nT-05 T-10 T-17 T-18", fillcolor="#fecaca"];
    oidccb [label="OIDC callback\nT-02 T-05", fillcolor="#fecaca"];
    alink  [label="Account-access link\nT-10 T-18", fillcolor="#fecaca"];
    elink  [label="Exam invitation link\nT-10 T-30", fillcolor="#fed7aa"]; }
  subgraph cluster_read  { label="Read surface"; style=rounded;
    chartep [label="Chart dataset\nT-01 T-04 T-12 T-19", fillcolor="#fecaca"];
    ranked  [label="Ranked list\nT-01 T-11 T-19", fillcolor="#fecaca"];
    detail  [label="Score detail\nT-01", fillcolor="#fed7aa"];
    export  [label="Self export\nT-01 T-24", fillcolor="#fed7aa"];
    examget [label="Exam fetch\nT-03 T-15", fillcolor="#fecaca"];
    asset   [label="Protected asset read\nT-09", fillcolor="#fed7aa"];
    audit   [label="Audit trail read\nT-22"]; }
  subgraph cluster_write { label="Write surface"; style=rounded;
    scorew  [label="Score write (assessor)\nT-08 T-20 T-21 T-22", fillcolor="#fed7aa"];
    selfw   [label="Score write (self)\nT-14 T-20"];
    submit  [label="Exam submit\nT-07 T-15 T-20 T-21", fillcolor="#fecaca"];
    examdef [label="Exam definition CRUD\nT-02 T-03", fillcolor="#fecaca"];
    roles   [label="Account and role CRUD\nT-02 T-06 T-22", fillcolor="#fecaca"];
    importe [label="Bulk import\nT-08 T-19 T-24 T-27", fillcolor="#fed7aa"];
    del     [label="Personal-data deletion\nT-25 T-22"]; }
}
```

---

## Diagram coverage note

Five diagram types are complete. What is **not** represented, because the consolidated model does not
contain it:

- **Deployment topology** — no cloud provider, network zones, load balancers or subnets exist (`SQ-8`).
- **Sequence diagrams** — no API contract exists to sequence; stage 09 would need one.
- **Physical data model** — no schema exists, so the DFD annotates data *classes*, not tables.
