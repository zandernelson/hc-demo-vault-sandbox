## 📌 Windsurf Prompt — Vault LDAP Static Role Validation (with Command Log)

### Context

I am a HashiCorp Solutions Engineer validating **documented Vault behavior**, not designing a solution or troubleshooting a customer environment.

A customer (GEICO) asked whether Vault’s **LDAP secrets engine static roles** can be configured so that:

* Vault does **not automatically rotate** an Active Directory service account password
* Password rotation happens **only when manually triggered** (e.g. `vault write -f ldap/rotate-role/<role>`)

HashiCorp Support confirmed:

* Automatic rotation **cannot be disabled** for LDAP static roles by design
* The supported workaround is to set `rotation_period` to the maximum allowed value (`999999h`, ~114 years), which effectively prevents scheduled rotation
* `skip_import_rotation=true` prevents Vault from rotating the password on role creation, but Vault cannot return a password until at least one rotation has occurred

My goal is to **lightly validate** this behavior in my own Vault environment so I can confidently confirm Support’s answer — not to explore alternative designs or edge cases.

---

### My Environment

* Vault OSS running on a manually provisioned EC2 instance
* OS: Amazon Linux 2
* Vault is already installed and unsealed (KMS auto-unseal)
* No LDAP server is currently configured
* Docker is installed but not yet used
* This is a disposable validation setup

---

### What I Want To Validate (Strict Scope)

Only validate the following:

1. Vault accepts `rotation_period=999999h` for an LDAP static role
2. When `skip_import_rotation=true`:

   * `vault read ldap/static-cred/<role>` returns `password: n/a` before rotation
3. After manual rotation (`vault write -f ldap/rotate-role/<role>`):

   * Vault returns a password
4. No additional automatic rotation occurs (we are not waiting 114 years — just confirming config + behavior)

---

### What I Do NOT Want

* No production hardening
* No AD integration
* No security posture discussion
* No alternative Vault patterns
* No long-running observation or automation
* No customer-facing documentation

This is **purely a functional validation** aligned with Support’s guidance.

---

### Tasks for You (Windsurf)

1. Confirm Docker is installed and running on Amazon Linux 2
2. Run a minimal OpenLDAP server using Docker (throwaway container is fine)
3. Configure Vault’s LDAP secrets engine to point to this LDAP server
4. Create a test LDAP user that Vault can manage
5. Create an LDAP static role using:

   * `skip_import_rotation=true`
   * `rotation_period=999999h`
6. Demonstrate:

   * `vault read ldap/static-cred/<role>` before rotation (password is `n/a`)
   * Manual rotation via `vault write -f ldap/rotate-role/<role>`
   * Successful password retrieval after rotation
7. Keep commands concise and explain only what is necessary

---

### **Required Output Artifact**

After completing the validation, create a file named:

```
vault-ldap-static-role-validation-commands.md
```

This file must contain:

* **Every command you executed**, in the exact order run
* A **short comment above each command** explaining:

  * What the command does
  * Why it was run (in the context of validating Support’s guidance)

Formatting requirements:

* Use Markdown
* Use fenced code blocks for commands
* Keep explanations brief and factual
* Do **not** include analysis, speculation, or recommendations

This file is intended as an internal validation record.

---

### Success Criteria

I should walk away with:

* A working minimal validation
* A clear command log artifact
* Confidence that Support’s answer is correct
* No additional complexity introduced

---

### Clarification Rule

If anything is ambiguous or requires assumption, **pause and ask before proceeding**.