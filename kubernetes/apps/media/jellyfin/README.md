# Jellyfin

## LDAP

```
LDAP Server:
ak-outpost-jellyfin-ldap.authentik.svc.cluster.local
LDAP Port:
389
LDAP Bind User:
cn=jellyfin-ldap-bind,ou=users,dc=blarc,dc=my,dc=id
LDAP Bind User Password:
<JELLYFIN_LDAP_BIND_TOKEN from Authentik>
LDAP Base DN for searches:
dc=blarc,dc=my,dc=id
LDAP Search Filter:
(objectClass=user)
LDAP Search Attributes:
cn, uid, mail, name
LDAP Uid Attribute:
cn
LDAP Username Attribute:
cn
```

If it does not work, try `Authentik > Providers > Ldap provider > Edit > Direct binding & Direct querying`.

Also, useful for debugging ([source](https://docs.goauthentik.io/add-secure-apps/providers/ldap/create-ldap-provider/#configuration-verification)):
```bash
ldapsearch -x \
    -H ldap://localhost:3389 \
    -D 'cn=jellyfin-ldap-bind,ou=users,dc=blarc,dc=my,dc=id' \
    -w 'password' \
    -b 'dc=blarc,dc=my,dc=id' \
    '(objectClass=user)'
```