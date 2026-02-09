# Vault Learning Plan

> **Learner:** Senior Solutions Engineer @ HashiCorp
> **Background:** Platform Engineering, Software Development
> **Environment:** Vault 1.21.2, Raft storage, AWS KMS auto-unseal, Amazon Linux 2023 EC2, Docker available
> **Goal:** Expert-level Vault knowledge

---

## Phase 1: Foundations
- [x] **1.1 Architecture & Internals** — barrier, seal/unseal, storage, cluster topology
- [ ] **1.2 Seal/Unseal & Auto-Unseal** — Shamir vs AWS KMS, recovery keys, seal wrap
- [ ] **1.3 Server Configuration** — HCL config file, listeners, storage stanza, telemetry
- [x] **1.4 CLI & API Basics** — environment variables, `vault status`, HTTP API, output formats
- [ ] **1.5 Vault UI** — enabling, navigating, capabilities

## Phase 2: Authentication
- [~] **2.1 Token Fundamentals** — root, service, batch, orphan, periodic, accessors, TTLs *(intro covered, deep dive pending)*
- [x] **2.2 Userpass Auth** — hands-on: enable, create user, login, attach policy
- [ ] **2.3 AppRole Auth** — role_id + secret_id, machine-to-machine auth patterns
- [ ] **2.4 AWS Auth** — IAM method, EC2 method (relevant to your environment)
- [ ] **2.5 Kubernetes Auth** — service account JWT, bound SA/NS (prep for VSO)
- [ ] **2.6 OIDC / JWT / LDAP** — SSO integration patterns

## Phase 3: Policies & Identity
- [x] **3.1 Policy Language** — HCL paths, capabilities, globs, deny *(basics covered, wrote demo-reader policy)*
- [ ] **3.2 Advanced Policies** — templated policies, parameter constraints, Sentinel (Enterprise)
- [ ] **3.3 Identity Engine** — entities, aliases, groups (internal & external)
- [ ] **3.4 Identity Templating** — dynamic policy paths using identity metadata

## Phase 4: Secrets Engines
- [x] **4.1 KV v2** — CRUD, versioning, metadata, CAS, soft delete/destroy
- [ ] **4.2 Transit** — encrypt/decrypt, key rotation, rewrap, signing, convergent encryption
- [ ] **4.3 PKI** — root CA, intermediate CA, cert issuance, CRL, OCSP, ACME
- [ ] **4.4 Database** — dynamic creds (spin up MySQL/Postgres via Docker), static roles, rotation
- [ ] **4.5 AWS Secrets Engine** — dynamic IAM users, STS assumed roles
- [ ] **4.6 SSH** — signed certificates, OTP mode
- [ ] **4.7 Transform / KMIP** — tokenization, FPE, key management

## Phase 5: Operational Mastery
- [ ] **5.1 Integrated Storage (Raft)** — peers, snapshots, autopilot, backup/restore
- [ ] **5.2 High Availability** — active/standby, request forwarding, health checks
- [ ] **5.3 Audit Devices** — enable file/syslog, HMAC, audit log analysis
- [ ] **5.4 Lease Management** — renew, revoke, prefix revocation, TTL tuning
- [ ] **5.5 Monitoring & Telemetry** — Prometheus metrics, key metrics, alerting
- [ ] **5.6 Upgrades & Migration** — rolling upgrades, seal migration

## Phase 6: Kubernetes & VSO
- [ ] **6.1 Vault on Kubernetes (Helm)** — deployment modes, Helm values
- [ ] **6.2 Agent Injector** — sidecar injection, annotations, templates
- [ ] **6.3 Vault Secrets Operator (VSO)** — CRDs, VaultStaticSecret, VaultDynamicSecret, VaultPKISecret
- [ ] **6.4 CSI Provider** — SecretProviderClass, volume mounts
- [ ] **6.5 End-to-End K8s Lab** — full pipeline from Vault secret to running pod

## Phase 7: Enterprise & Advanced
- [ ] **7.1 Namespaces** — multi-tenancy, hierarchical isolation
- [ ] **7.2 Replication** — performance replication, DR replication, promotion/demotion
- [ ] **7.3 Control Groups & MFA** — multi-person approval workflows
- [ ] **7.4 Sentinel Policies** — RGP, EGP, governance at scale
- [ ] **7.5 Response Wrapping** — cubbyhole, secure introduction, broker pattern

## Phase 8: Integration & Real-World Patterns
- [ ] **8.1 Vault + Terraform** — provider config, managing Vault as code
- [ ] **8.2 CI/CD Integration** — GitHub Actions, GitLab CI, Jenkins
- [ ] **8.3 Service Mesh & mTLS** — PKI + Consul Connect / Envoy
- [ ] **8.4 HCP Vault** — managed Vault, HCP Vault Secrets (SaaS)
- [ ] **8.5 Customer Demo Scenarios** — common SE demo flows, objection handling

---

*Last updated: 2026-02-06 — Session 1 in progress*
