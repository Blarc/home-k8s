# Repository guidance for agents

This repository manages a home Kubernetes cluster running Talos, plus configuration for its NAS server. Keep changes declarative and consistent with nearby examples.

## Repository layout

- `talos/` contains Talos and Talhelper configuration. `talconfig.yaml` is the source configuration; generated machine configuration is under `talos/clusterconfig/`. Secret material is SOPS-encrypted.
- `nas/` contains Ansible inventory, playbooks, and playbook variables for configuring the NAS.
- `kubernetes/apps/` contains Argo CD-managed Helm releases, grouped by Kubernetes namespace. Application charts and their values live below the namespace directory, commonly as `kubernetes/apps/<namespace>/<application>/`.
- Read a component's README and inspect sibling configurations before changing it. Some infrastructure apps use custom Helm templates or upstream charts rather than bjw-s app-template.

## Adding or changing Kubernetes applications

- For a new application, use the bjw-s-labs `app-template` Helm dependency by default. Follow a nearby chart's `Chart.yaml`, values structure, dependency version, and lock-file conventions.
- Use an upstream chart when it is a better fit for the application or repository precedent points to it. Keep application-specific resources in Helm templates when that matches nearby examples.
- Put the release under its namespace directory. Follow the existing Argo CD and namespace conventions; inspect `kubernetes/apps/argo-cd/templates/apps.yaml` when changing how releases are discovered or deployed.
- Keep credentials and other sensitive values encrypted with the repository's SOPS configuration. Never add plaintext secrets. Preserve existing encrypted files unless the task requires changing them.
- For chart changes, use local Helm linting or rendering when dependencies are available. Do not use a live `kubectl apply` or Argo CD sync as validation.

## Traefik routing and proxy authentication

- Traefik is configured in `kubernetes/apps/traefik/values.yaml`, with Gateway resources in its `templates/` directory. It uses the Kubernetes Gateway API and Traefik CRD providers; the Kubernetes Ingress provider is disabled. Add application routes with app-template `route` values or `HTTPRoute` templates.
- For internal applications, use hostname `<release>.blarc.my.id` and `parentRefs: [{ name: internal, namespace: traefik }]`. The internal Gateway accepts routes from all namespaces. Its LoadBalancer IP is `192.168.1.228`; service ports 80/443 map to Traefik entrypoints 8000/8443.
- For intentionally public applications, use the `external` Gateway in namespace `traefik`. It accepts routes only from namespaces labeled `external: "true"`. Its LoadBalancer IP is `192.168.1.229`; service ports 80/443 map to entrypoints 9000/9443. The external Gateway has an external-dns target annotation; check the template before changing public DNS or exposure. A separate `planreply` Gateway handles `planreply.eu` on these external entrypoints.
- Both wildcard Gateways serve `*.blarc.my.id`, redirect HTTP to HTTPS, and terminate TLS using cert-manager certificates (`letsencrypt-prod`, secrets `internal-certificate` and `external-certificate`). Backends normally use HTTP to their ClusterIP service. External HTTPS entrypoints also apply the CrowdSec bouncer middleware; this does not replace application authentication.
- Routing and TLS alone do not require users to sign in. Proxy login uses Authelia at `http://authelia.auth.svc.cluster.local/api/authz/forward-auth`, through a namespaced Traefik `Middleware` with `spec.forwardAuth`, `trustForwardHeader: true`, and `maxResponseBodySize: 8192`. Attach it to each protected `HTTPRoute` rule with an `ExtensionRef` filter (`group: traefik.io`, `kind: Middleware`, `name: <middleware-name>`).
- Use `kubernetes/apps/media/slskd/` as an example of proxy authentication with a chart-owned, release-prefixed middleware name. Prefer unique middleware names for new charts to avoid multiple Argo CD applications owning the same resource. Existing Scryer and Dufs charts share the name `authelia-forward-auth`; do not copy that ownership pattern into new charts. Put middleware and NetworkPolicy resources in wave `-2`, backend Services and workloads in the default wave `0`, and HTTPRoutes in wave `1`. A route in an earlier wave than its backend can fail health checks for a missing Service and block Argo from ever creating that Service.
- Authelia's access rules live in `kubernetes/apps/auth/authelia/values.yaml`. The current default is `one_factor`, with explicit user restrictions for some hosts. Check these rules when adding a protected application; attaching middleware does not itself restrict access to a particular user.
- When disabling an application's built-in authentication in favor of Authelia, restrict direct access to its HTTP port with a NetworkPolicy. Allow Traefik pods using both the `traefik` namespace selector and `app.kubernetes.io/name: traefik` pod selector. Add narrow allowances for required internal API clients, such as DroppedNeedle accessing slskd. Keep peer/download protocol ports separate from HTTP allowances. Check whether disabling authentication also disables API-key enforcement, and document client configuration accordingly.
- External DNS consumes Gateway HTTPRoutes, Services, and DNSEndpoint resources via `kubernetes/apps/external-dns/values.yaml`. Keep routing, DNS, TLS, and authentication changes declarative; validate with Helm rendering without applying or syncing the cluster.

## Talos and NAS changes

- Read the relevant README and nearby configuration before editing Talos or Ansible files.
- Preserve the repository's SOPS encryption for secret-bearing configuration. Do not expose decrypted values in logs, commits, or generated documentation.
- Do not apply Talos configuration, bootstrap or upgrade nodes, change the live Kubernetes cluster, or run NAS playbooks unless the user explicitly requests that operation.

## Working tree and scope

- Check `git status` before editing and preserve unrelated user changes, including untracked files.
- Keep changes focused on the requested work. Do not regenerate generated configuration or dependency files unless the change requires it.
