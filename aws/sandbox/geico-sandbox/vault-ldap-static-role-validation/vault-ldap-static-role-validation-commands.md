# Vault LDAP Static Role Validation — Command Log

**Date:** 2026-02-09
**Vault Version:** 1.21.2 (OSS)
**Environment:** Amazon Linux 2, EC2, disposable sandbox
**Purpose:** Validate HashiCorp Support's guidance that LDAP static roles cannot disable automatic rotation, but `rotation_period=999999h` and `skip_import_rotation=true` effectively achieve manual-only rotation behavior.

---

## 1. Confirm Docker is installed and running

<!-- Docker was installed but the daemon was not running. Start it. -->

```bash
docker --version
```

```bash
sudo systemctl start docker
sudo systemctl status docker --no-pager
```

---

## 2. Launch a minimal OpenLDAP server via Docker

<!-- Disposable OpenLDAP container for Vault to bind to. Uses osixia/openldap with a known admin password and base DN dc=example,dc=com. -->

```bash
sudo docker run -d --name openldap \
  -p 389:389 \
  -e LDAP_ORGANISATION="Example" \
  -e LDAP_DOMAIN="example.com" \
  -e LDAP_ADMIN_PASSWORD="adminpassword" \
  osixia/openldap:1.5.0
```

<!-- Wait for slapd to finish initializing before proceeding. -->

```bash
sleep 8
sudo docker logs openldap 2>&1 | tail -5
```

---

## 3. Create LDAP OU and test user

<!-- Create an organizational unit and a test user that Vault will manage. Commands are run inside the container using a file-based LDIF approach because stdin piping with docker exec silently fails with this image. -->

```bash
sudo docker exec openldap bash -c 'cat > /tmp/ou.ldif << EOF
dn: ou=users,dc=example,dc=com
objectClass: organizationalUnit
ou: users
EOF
ldapadd -x -H ldap://$(hostname) -D "cn=admin,dc=example,dc=com" -w adminpassword -f /tmp/ou.ldif -v'
```

```bash
sudo docker exec openldap bash -c 'cat > /tmp/user.ldif << EOF
dn: cn=testuser,ou=users,dc=example,dc=com
objectClass: inetOrgPerson
objectClass: person
objectClass: top
cn: testuser
sn: User
uid: testuser
userPassword: initialpassword
EOF
ldapadd -x -H ldap://$(hostname) -D "cn=admin,dc=example,dc=com" -w adminpassword -f /tmp/user.ldif -v'
```

<!-- Verify the test user is searchable. -->

```bash
sudo docker exec openldap bash -c \
  'ldapsearch -x -H ldap://$(hostname) -b "ou=users,dc=example,dc=com" -D "cn=admin,dc=example,dc=com" -w adminpassword "(cn=testuser)" dn'
```

---

## 4. Enable and configure Vault LDAP secrets engine

<!-- Enable the LDAP secrets engine at the default path. -->

```bash
vault secrets enable ldap
```

<!-- Configure the engine to bind to the local OpenLDAP container using the admin account. schema=openldap is required for non-AD LDAP servers. -->

```bash
vault write ldap/config \
  binddn="cn=admin,dc=example,dc=com" \
  bindpass="adminpassword" \
  url="ldap://127.0.0.1:389" \
  userdn="ou=users,dc=example,dc=com" \
  userattr="cn" \
  schema="openldap"
```

---

## 5. Create LDAP static role with skip_import_rotation and maximum rotation_period

<!-- This is the core of the validation. rotation_period=999999h (~114 years) effectively prevents automatic rotation. skip_import_rotation=true prevents Vault from rotating the password at role creation time. -->

```bash
vault write ldap/static-role/testuser \
  username="testuser" \
  dn="cn=testuser,ou=users,dc=example,dc=com" \
  rotation_period="999999h" \
  skip_import_rotation=true
```

**Result:** Vault accepted both parameters without error.

---

## 6. Validation: Read credential before rotation

<!-- With skip_import_rotation=true and no manual rotation yet, Vault should return password: n/a. This confirms Support's statement that Vault cannot return a password until at least one rotation has occurred. -->

```bash
vault read ldap/static-cred/testuser
```

**Result:**

```
Key                    Value
---                    -----
dn                     cn=testuser,ou=users,dc=example,dc=com
last_password          n/a
last_vault_rotation    0001-01-01T00:00:00Z
password               n/a
rotation_period        999999h
ttl                    999998h59m53s
username               testuser
```

- `password: n/a` — confirmed, no password available before first rotation.
- `last_vault_rotation: 0001-01-01T00:00:00Z` — zero-value timestamp, no rotation has occurred.
- `ttl: 999998h59m53s` — next automatic rotation is ~114 years away.

---

## 7. Validation: Manual rotation

<!-- Trigger a manual password rotation. This is the only supported way to get an initial password when skip_import_rotation=true. -->

```bash
vault write -f ldap/rotate-role/testuser
```

**Result:** `Success! Data written to: ldap/rotate-role/testuser`

---

## 8. Validation: Read credential after rotation

<!-- After manual rotation, Vault should now return a real password. -->

```bash
vault read ldap/static-cred/testuser
```

**Result:**

```
Key                    Value
---                    -----
dn                     cn=testuser,ou=users,dc=example,dc=com
last_password          n/a
last_vault_rotation    2026-02-09T18:14:37.458349185Z
password               7XDVKPsIL9HNwUr9LLF5hiHDfLbRU3oCMtJOeWh4cCPkDgyTJrDjFM6QOEdmsu4b
rotation_period        999999h
ttl                    999998h59m30s
username               testuser
```

- `password` — real password returned after manual rotation.
- `last_vault_rotation` — valid timestamp confirming rotation occurred.
- `ttl: 999998h59m30s` — next automatic rotation remains ~114 years away.

---

## Summary of Findings

| Validation Point | Expected | Observed | Status |
|---|---|---|---|
| Vault accepts `rotation_period=999999h` | Accepted | Accepted | ✅ |
| `skip_import_rotation=true` prevents rotation on role creation | `password: n/a` | `password: n/a` | ✅ |
| Manual rotation via `vault write -f ldap/rotate-role/<role>` succeeds | Success | Success | ✅ |
| Password returned after manual rotation | Real password | Real password | ✅ |
| No automatic rotation imminent (TTL ~114 years) | ~999999h TTL | 999998h59m30s | ✅ |

All behaviors match HashiCorp Support's guidance.
