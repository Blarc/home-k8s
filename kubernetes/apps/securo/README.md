# Securo

Deploys the [official Securo Helm chart](https://github.com/securo-finance/securo/tree/main/charts/securo)
from `oci://ghcr.io/securo-finance/charts/securo`, pinned to `0.16.6`, in the
`securo` namespace. The existing Argo CD ApplicationSet discovers this
wrapper and loads `values.encrypted.yaml`; the namespaces application manages
`namespace.yaml`.

## Access and components

Open **https://securo.blarc.my.id** from the internal network. The wrapper's
HTTPRoute uses Traefik's `internal` Gateway, routing `/api` to the backend
Service on 8000 and `/` to the frontend Service on 3000 (container port 8080).
It is created at sync wave `1`, after the official chart's Services. Upstream
Ingress and HTTPRoute generation are disabled to avoid duplicate routes.
TLS terminates at the existing Gateway.

Securo's built-in login remains enabled alongside Authelia OIDC; complete
initial account setup on first access. Enable Banking has credential
placeholders; AI agents and Authelia proxy login are not configured. The official chart deploys the frontend, backend, Celery
worker, singleton beat replica, Redis, and database migration Job. Application
images are pinned to `0.16.6`. Workload update strategies and probes follow the
official chart defaults.

## OIDC (Authelia)

Choose **Authelia** on Securo's login page. The `securo` client uses discovery
at `https://auth.blarc.my.id/.well-known/openid-configuration` and callback
`https://securo.blarc.my.id/api/auth/oidc/callback`. Authelia requires S256 PKCE
and `client_secret_post`, matching Securo's authorization-code implementation.
Deploy both charts' changes before using OIDC.

The raw client secret is SOPS-encrypted in this chart's `values.encrypted.yaml`
and rendered into `securo-secret`. Its matching PBKDF2 digest is encrypted in
Authelia's values and mounted from `authelia-oidc` as `securo.client_secret`.
The client requests `openid profile email`, and Authelia's `securo` claims
policy includes the verified email and profile claims in the ID token.

Any Authelia user may sign in with one-factor authentication and create a
Securo account while registration is enabled. An existing Securo account is
linked only when Authelia supplies the same verified email address. Create
the initial administrator through local setup, using the same email as its
Authelia identity, before signing in with OIDC. Role synchronization is
disabled; administrator privileges remain managed inside Securo. Local login
remains available.

## Enable Banking

Fill in the empty placeholders with `sops kubernetes/apps/securo/values.encrypted.yaml`:

```yaml
secret:
  enableBankingAppId: "your-application-id"
  enableBankingPrivateKey: |
    -----BEGIN PRIVATE KEY-----
    your-PEM-private-key
    -----END PRIVATE KEY-----
```

Use the application ID and complete PEM private key from Enable Banking.
The key is passed as `ENABLE_BANKING_PRIVATE_KEY` through `securo-secret`,
so no key file or volume mount is needed. Backend, worker, and scheduler
consume this Secret. Empty placeholders keep the provider unconfigured.

Register **https://securo.blarc.my.id/oauth/callback** as an Allowed Redirect
URL in the Enable Banking application, exactly as written. The API endpoint
is `https://api.enablebanking.com`. See
[Securo's Enable Banking setup](https://github.com/securo-finance/securo#enable-banking--european-banks-psd2).
After filling the credentials, deploy the updated Secret and restart backend,
worker, and scheduler so they read the new environment values. The official
chart does not automatically restart these workloads for Secret-only changes.

## Database, credentials, and storage

CloudNativePG is retained instead of the upstream bundled PostgreSQL, whose
chart hard-codes its database credentials. PostgreSQL settings are hardcoded
in `templates/postgresql-cluster.yaml`. The wrapper creates one instance with
a 5Gi `topolvm-thin-retain` volume using CNPG's official PostgreSQL
`16.15-standard-trixie` image. PostgreSQL 16 matches Securo 0.16.6's upstream
deployment and CI. CNPG's standard image already includes pgvector, so no
separate extension image or ImageVolume feature is needed. A CNPG `Database`
resource declaratively installs `vector` and `pgcrypto` in the `securo`
database, using the extension versions bundled with the image. See
[CNPG standard images](https://github.com/cloudnative-pg/postgres-containers#standard-images)
and [declarative database management](https://cloudnative-pg.io/docs/1.30/declarative_database_management/).
The official chart connects using `global.existingSecret`
(`securo-secret`), containing `SECRET_KEY`, `DATABASE_URL`, `OIDC_CLIENT_ID`,
and `OIDC_CLIENT_SECRET`.

Application and database credentials remain in `values.encrypted.yaml`,
encrypted for the personal and Argo CD age recipients. Secrets use sync wave
`-2`, and the Cluster and Database use `-1`. Changing the database bootstrap Secret alone
does not rotate an existing database password.

The official chart provisions a 5Gi `ReadWriteMany` NFS attachment PVC shared
by the application workloads, plus a 2Gi Redis volume using the cluster's
default storage class (`topolvm-thin`). Redis configuration follows upstream
defaults. Agent PVCs are configured for shared NFS storage but are not created
while agents are disabled.

CloudNativePG with declarative extension management, its Cluster and Database
CRDs, NFS and TopoLVM storage classes, and Traefik's internal Gateway must
already exist. The installed CNPG 1.30.1 operator supports this configuration.
The NFS export must allow application containers to write attachments.

Migrations use the official chart's `post-install,post-upgrade` Helm hook,
which Argo CD treats as PostSync. The Job retries migrations while the database
starts. API health probes do not verify schema readiness, so deployment is
complete only after the migration Job succeeds. Initial background tasks may
run before migrations finish.

## Local validation

From the repository root:

```sh
helm dependency build kubernetes/apps/securo --skip-refresh
helm lint kubernetes/apps/securo \
  --set secret.secretKey=local-validation-only \
  --set secret.databasePassword=local-validation-only \
  --set secret.oidcClientSecret=local-validation-only
helm template securo kubernetes/apps/securo --namespace securo \
  --set secret.secretKey=local-validation-only \
  --set secret.databasePassword=local-validation-only \
  --set secret.oidcClientSecret=local-validation-only
```

These placeholders are for local rendering only. Argo CD uses encrypted
credentials. Local validation does not apply resources or synchronize Argo CD.
