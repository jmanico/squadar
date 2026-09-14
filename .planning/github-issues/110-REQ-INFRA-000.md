# [REQ-INFRA-000] Terraform infrastructure and delivery pipeline

> **BLOCKED — do not implement.** Blocked on `PQ-9`. See **Open Decisions**.

## Metadata

- **ID**: REQ-INFRA-000
- **Title**: Terraform infrastructure and delivery pipeline
- **Version**: 0.1.0
- **Status**: Draft
- **Owner**: Squadar engineering — unassigned
- **Author**: Jim Manico
- **Last Updated**: 2026-09-14
- **Priority**: High
- **Requirement Type**: Operational
- **Source / Parent**: REQ-EPIC-001; `ARCHITECTURE.md` deployment model; `SECURITY.md` SEC-CICD-1…6

## Requirement

- **Statement**: Application and infrastructure changes MUST reach any shared environment only through a reviewed pipeline from version control, with Terraform-managed infrastructure that is scanned before apply and state held in a protected remote backend; delivery is the sum of its children.
- **Rationale**: `ARCHITECTURE.md` names Terraform as the deployment model and `SECURITY.md` states six CI/CD rules. `CLAUDE.md` records the release process as `TO BE DECIDED` because no deployment target exists (`SQ-8`).
- **Assumptions**: None — the cloud provider, CI system and runtime topology are `UNKNOWN`.
- **Out of Scope**: Cannot be stated until `PQ-9` is answered.
- **Design Traceability**: N/A — this workstream ships no user-facing surface.
- **Architecture Traceability**: `ARCHITECTURE.md` Relational Data Store, Protected Asset Store, deployment model; DR-10 (no rule names a cloud provider or topology, and none becomes invalid once they are chosen).
- **Security Traceability**: SEC-CICD-1…SEC-CICD-6, SEC-SECRET-1, SEC-SECRET-2, SEC-DATA-1, SEC-HTTP-1, SEC-HTTP-4, SEC-HTTP-7, DEP-7.

## Scope

- **Applies To**: Multiple
- **Components**: Deployment pipeline; Terraform-managed infrastructure; Relational Data Store; Protected Asset Store
- **Interfaces / Operations**: Build, scan, review and apply; environment provisioning; secret storage; artifact publication
- **Actors**: Developers; the pipeline identity; the Terraform execution identity
- **Preconditions**: A cloud provider and CI system have been chosen
- **Data Classification**: Restricted — state may contain sensitive values
- **Personal or Regulated Data**: Personal Data — the provisioned stores hold it, though the configuration itself does not
- **Jurisdiction / Regulatory Scope**: TO BE DECIDED — `PQ-13`; data residency would follow from the provider choice

## Security Context

- **Security Objectives**: Multiple
- **Control Layers**: Architecture, Data Protection, Supply Chain, Logging and Monitoring
- **Threat References**: STRIDE — Tampering (unreviewed change reaching a shared environment), Information Disclosure (state or secrets committed), Elevation of Privilege (shared or over-privileged pipeline identity)
- **Abuse / Misuse Case**: A console deployment bypassing review; Terraform state committed to the repository; a data store or asset store provisioned publicly reachable; a pipeline identity shared between production and non-production.
- **Trust Boundary**: Version control → pipeline → shared environment
- **Untrusted Inputs or Assertions**: Pull-request content, third-party Terraform modules and provider plugins
- **Authoritative Enforcement Point**: Branch protection and the pipeline — a direct console or local apply MUST NOT be a supported path (SEC-CICD-1)
- **Independent Verification**: IaC scanning in CI, independent of the author's local run (SEC-CICD-3); artifact traceability to the reviewed commit and lockfile (SEC-CICD-5)
- **Zero Trust Relevance**: NIST SP 800-207 §2.1 tenet 5 — the integrity and security posture of the deployed assets is monitored and measured rather than assumed

## Standards Alignment

- **OWASP ASVS 5.0.0**: TO BE DECIDED — `PQ-17`
- **OWASP AISVS 1.0**: N/A
- **NIST SP 800-53 Rev. 5**: N/A — no mapping verified against the catalog release
- **NIST SP 800-207**: §2.1 tenet 5
- **Regulatory**: TO BE DECIDED — `PQ-13`
- **Other**: `SECURITY.md` DEP-7 (frozen, reproducible dependency resolution in production and CI builds)
- **Mapping Basis**: Tenet 5 is cited because SEC-CICD-3 and SEC-CICD-5 require measured posture and artifact provenance rather than trust in the deploying party.

## Acceptance Criteria

Concrete criteria depend on the provider, CI system and topology, all `UNKNOWN`. Writing them now
would invent technology choices, which this decomposition MUST NOT do. Two criteria hold regardless
and are stated; the rest are deferred until `PQ-9` is answered.

1. **AC-01 — Expected behavior**: TO BE DECIDED — blocked on `PQ-9`.
2. **AC-02 — Boundary or failure behavior**: Given a failing security check in the pipeline, when a merge is attempted, then the merge is blocked (SEC-CICD-6). This holds regardless of how `PQ-9` is answered.
3. **AC-03 — Prohibited behavior**: Given the repository, when it is inspected, then no Terraform state file and no credential, signing key or provider secret MUST be tracked in it (SEC-CICD-4, SEC-SECRET-1). This holds regardless of how `PQ-9` is answered and is already enforced by `.claude/hooks/protect-files.sh` and `permissions.deny` in `.claude/settings.json`.

## Failure Behavior

- **On Invalid Input**: A Terraform plan that fails scanning is refused before apply (SEC-CICD-3)
- **On Authentication Failure**: N/A
- **On Authorization Failure**: A pipeline identity lacking the permission for its stage fails the stage rather than escalating (SEC-CICD-2)
- **On Security-Decision Failure**: Deny by default — a failing check blocks the merge (SEC-CICD-6)
- **On External Dependency Failure**: A provider or registry outage fails the build; it MUST NOT fall back to floating resolution (DEP-7)
- **On System Error**: A partially applied Terraform run is reported and reconciled, never left silently divergent
- **Logging / Audit**: Pipeline runs and applies recorded with actor, action, target and timestamp (SEC-LOG-2); no secret values in build logs (SEC-SECRET-1, SEC-LOG-3)
- **Alerting**: TO BE DECIDED — depends on the chosen CI system

## Test Strategy

- **Unit Tests**: N/A — configuration, not code with unit-testable behavior
- **Integration Tests**: A plan-and-scan dry run per environment once the provider is chosen
- **Security Tests**: IaC scanning for insecure settings (SEC-CICD-3); repository check that no state file is tracked (SEC-CICD-4); secret scanning over source, bundles and IaC (SEC-SECRET-1); identity-to-permission mapping review (SEC-CICD-2); artifact metadata check (SEC-CICD-5)
- **Compliance Tests / Evidence**: TO BE DECIDED — `PQ-13`
- **Acceptance-Criteria Traceability**: AC-02 by the pipeline configuration review; AC-03 by the repository check and the existing hooks; AC-01 deferred
- **Coverage Target**: Every SEC-CICD rule with an automatable verification method has a check that runs before merge (SEC-CICD-6)
- **Required Test Environment**: A non-production environment distinct from production, with its own identity (SEC-CICD-2)

## Dependencies

- **Upstream Requirements**: REQ-FOUND-010
- **Downstream Requirements**: None — but no workstream reaches production without this one
- **Child Requirements**: TO BE DECIDED — none can be enumerated until `PQ-9` is answered
- **External Dependencies**: Cloud provider (`UNKNOWN`), CI system (`UNKNOWN`), remote Terraform state backend (`TO BE DECIDED`), IaC scanning tool (`TO BE DECIDED`), secret store (`TO BE DECIDED`)
- **Dependency Assumptions**: None can be made while the providers are unknown; each will need its own review under DEP-1…DEP-8 and SEC-EXT-1.
- **Failure Impact**: Without this workstream there is no supported path to a shared environment; nothing ships.

## Implementation Notes

- **Constraints**: DR-10 — no architectural rule may be invalidated by the provider choice, so the configuration realizes the existing component boundaries rather than redefining them.
- **Prohibited Approaches**: Direct console or local apply to a shared environment; committed state; a shared pipeline identity across environments; a publicly reachable data or asset store without documented intent
- **Implementation Guidance**: None until the provider is chosen — guidance written now would presuppose the answer to `PQ-9`.
- **AI Development Guidance**: `CLAUDE.md`; do not implement this workstream while it is BLOCKED. `.claude/hooks/block-dangerous.sh` already blocks destructive infrastructure commands.
- **Required Human Review**: Architecture and security review of the provider decision and of every Terraform change before apply (SEC-CICD-3)
- **Open Decisions**: **`PQ-9` (blocking)** — which cloud provider, CI system and runtime topology Terraform will provision, and where environments live (`SQ-8`, and `CLAUDE.md`'s "Release process: TO BE DECIDED"). Until answered, this workstream has no leaves and MUST NOT be implemented.
