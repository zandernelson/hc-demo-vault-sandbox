# Customer Response — Vault LDAP Static Role Manual-Only Rotation

---

Hi team,

Following up on your question about configuring Vault's LDAP secrets engine static roles to support **manual-only password rotation** — I've independently validated the workaround that HashiCorp Support recommended, and I can confirm it works as described.

## Summary

Vault's LDAP secrets engine **does not natively support disabling automatic rotation** for static roles — `rotation_period` is a required field and cannot be set to zero or omitted. However, the following configuration effectively achieves manual-only rotation:

```hcl
rotation_period      = "999999h"    # ~114 years — auto-rotation will never practically trigger
skip_import_rotation = true         # Vault will NOT rotate the password when the role is first created
```

With this configuration:

- **No password change occurs at role creation** — your existing AD service account password remains intact.
- **Vault will not automatically rotate the password** — the scheduled rotation is ~114 years away.
- **You control when rotation happens** by explicitly running:

  ```bash
  vault write -f ldap/rotate-role/<role-name>
  ```

- **Each manual rotation resets the auto-rotation timer** back to ~114 years, so as long as the role is used, automatic rotation never fires.

## What I Validated

I stood up a test environment with Vault 1.21.2 and an OpenLDAP server and confirmed:

| Test | Result |
|---|---|
| Vault accepts `rotation_period=999999h` | ✅ Accepted |
| `skip_import_rotation=true` prevents password change on role creation | ✅ Confirmed — `password: n/a` returned |
| Manual rotation generates and pushes a new password | ✅ Confirmed |
| Password retrievable from Vault after manual rotation | ✅ Confirmed |
| Auto-rotation timer set to ~114 years after rotation | ✅ Confirmed |

## Critical Items to Be Aware Of

1. **Vault cannot return a password until the first rotation.** When using `skip_import_rotation=true`, the credential endpoint returns `password: n/a` until you manually trigger at least one rotation. Any applications or automation pulling credentials from Vault will need to account for this during initial setup.

2. **This is a workaround, not a built-in feature.** There is no native "disable auto-rotation" toggle. The 999999h value is the maximum accepted by Vault. If HashiCorp introduces a first-class manual-only option in a future release, migrating to it would be advisable.

3. **Plan your first rotation.** After creating the static role, you will need to coordinate the first `vault write -f ldap/rotate-role/<role>` with any systems that depend on the AD account password, since that rotation **will change the password in AD**.

4. **Audit log visibility.** The `rotation_period: 999999h` value will appear in Vault audit logs and role configuration reads. Consider adding internal documentation so other Vault operators understand the intent behind this value.

---

Let me know if you have any questions or need further detail on the configuration steps.
