# Vault LDAP Static Role — Manual-Only Rotation Workaround

## The Situation

A customer needs Vault to manage an Active Directory service account password via the **LDAP secrets engine static roles** feature, but with a specific constraint: Vault should **not automatically rotate** the password on a schedule. Instead, rotation should only happen when **explicitly triggered** by an operator or automation.

## The Problem

Vault's LDAP secrets engine **does not support disabling automatic rotation** for static roles. The `rotation_period` parameter is required and enforces a scheduled rotation cycle. There is no `disable_auto_rotation` flag or equivalent.

This is **by design** — static roles are built around the concept of Vault owning and periodically rotating the credential.

## The Workaround

HashiCorp Support confirmed the following approach:

### 1. Set `rotation_period` to the maximum allowed value

```
rotation_period = "999999h"
```

This sets the automatic rotation interval to **~114 years**, effectively making it a non-event. Vault still schedules it internally, but it will never fire in any practical timeframe.

### 2. Use `skip_import_rotation=true` on role creation

```
skip_import_rotation = true
```

By default, Vault rotates the password immediately when a static role is created (the "import rotation"). Setting this to `true` **skips that initial rotation**, meaning:

- Vault does **not** change the existing LDAP password on role creation
- `vault read ldap/static-cred/<role>` returns `password: n/a` until a rotation occurs
- The existing LDAP password remains unchanged and usable outside of Vault

### 3. Trigger rotation manually when ready

```bash
vault write -f ldap/rotate-role/<role>
```

This forces Vault to generate a new password and push it to LDAP. After this:

- `vault read ldap/static-cred/<role>` returns the new password
- The TTL resets to ~999999h (next auto-rotation is ~114 years away)
- The LDAP account now has the Vault-generated password

## How It Works Together

```
┌─────────────────────────────────────────────────────────┐
│  Role Creation (skip_import_rotation=true)               │
│  → No password rotation occurs                           │
│  → Vault returns password: n/a                           │
│  → Existing LDAP password remains intact                 │
├─────────────────────────────────────────────────────────┤
│  Manual Rotation (vault write -f ldap/rotate-role/...)   │
│  → Vault generates new password                          │
│  → Pushes to LDAP server                                 │
│  → password field now returns real value                  │
│  → TTL resets to ~999999h                                │
├─────────────────────────────────────────────────────────┤
│  Ongoing State                                           │
│  → Auto-rotation scheduled but ~114 years away           │
│  → Operator triggers rotation manually as needed         │
│  → Each manual rotation resets the TTL to ~999999h       │
└─────────────────────────────────────────────────────────┘
```

## Key Behaviors

| Behavior | Detail |
|---|---|
| `rotation_period` is required | Cannot be omitted or set to 0 |
| Maximum accepted value | `999999h` (~114 years) |
| `skip_import_rotation=true` | Prevents rotation at role creation |
| Password before first rotation | `n/a` — Vault has no password to return |
| Manual rotation | `vault write -f ldap/rotate-role/<role>` |
| TTL after rotation | Resets to full `rotation_period` |
| Each manual rotation | Resets the auto-rotation timer |

## Important Considerations

1. **Vault cannot return a password until at least one rotation has occurred.** If `skip_import_rotation=true` is used, the operator must manually rotate before any consumer can retrieve a credential from Vault.

2. **Each manual rotation resets the TTL.** This means the 114-year auto-rotation window restarts every time someone manually rotates — automatic rotation will effectively never trigger as long as the role is periodically used.

3. **This is a workaround, not a native feature.** There is no first-class "manual-only" mode. If HashiCorp adds one in a future release, it would be preferable to this approach.

4. **The `rotation_period` appears in audit logs and role reads.** The 999999h value is unusual and may prompt questions from other operators — consider documenting the intent internally.

## Validated On

- **Vault Version:** 1.21.2 (OSS)
- **LDAP Target:** OpenLDAP 2.4.57 (via Docker)
- **Date:** 2026-02-09
- **Result:** All behaviors match Support's guidance. See `vault-ldap-static-role-validation-commands.md` for the full command log.
