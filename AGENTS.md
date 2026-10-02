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

## Talos and NAS changes

- Read the relevant README and nearby configuration before editing Talos or Ansible files.
- Preserve the repository's SOPS encryption for secret-bearing configuration. Do not expose decrypted values in logs, commits, or generated documentation.
- Do not apply Talos configuration, bootstrap or upgrade nodes, change the live Kubernetes cluster, or run NAS playbooks unless the user explicitly requests that operation.

## Working tree and scope

- Check `git status` before editing and preserve unrelated user changes, including untracked files.
- Keep changes focused on the requested work. Do not regenerate generated configuration or dependency files unless the change requires it.
