# Talos

This cluster is managed with [topf](https://github.com/postfinance/topf).
The migration was validated with topf v0.6.2, keeping Talos at 1.13.7 and
Kubernetes at 1.36.4. Commands below run from this directory (`cd talos`).

## Install tools

Install topf, `talosctl`, and SOPS. For topf on macOS:

```bash
brew install postfinance/tap/topf
```

SOPS must have access to the existing personal age key to decrypt the cluster
configuration and secrets bundle.

## Configuration

- `topf.yaml`: cluster endpoint, versions, node inventory, and SOPS-encrypted
  cluster name and UPS settings in `data`.
- `talsecret.sops.yaml`: the original Talos secrets bundle, selected explicitly by
  `secretsPath` in `topf.yaml`. Preserve this bundle when managing the existing
  cluster; it contains its identity, certificates, and tokens.
- `schematic.yaml`: i915, Intel microcode, and NUT client system extensions.
  Topf computes its image-factory schematic ID locally.
- `all/`: shared patches, including hostnames derived from `nodes[].host`.
- `control-plane/`: cluster settings, kubelet settings, metrics listeners, and
  ingress firewall rules.
- `node/multi-role/`: install disk, kernel modules, static networking, and the
  NUT service template. The `/32` address and default route preserve the previous
  generated configuration.

Patches merge in the order `all/`, `<role>/`, then `node/<host>/`, with files in
each directory sorted lexicographically. `.yaml.tpl` files use Go templates;
UPS values come from the decrypted `.Data` fields in `topf.yaml`.

Edit encrypted values with:

```bash
sops topf.yaml
```

The repository's SOPS rules encrypt `clusterName` and all values under `data`.
The original `talsecret.sops.yaml` is unchanged. The Talhelper inputs
`talconfig.yaml` and `talenv.sops.yaml` have been replaced by this layout.
The old ignored `clusterconfig/` files are local historical artifacts; topf
does not read them.

## Render and validate

```bash
topf render --output output
talosctl validate --config output/multi-role.yaml --mode metal
```

Rendering is offline by default and writes a complete machine configuration,
including plaintext secrets, to `output/multi-role.yaml`. `output/`,
`talosconfig`, and `kubeconfig` are ignored by Git.

For this migration, the rendered documents were compared structurally with a
fresh Talhelper render using the same encrypted bundle and environment. They
matched exactly.
No configuration was applied to the node as part of the migration.

## Review and apply configuration

Preview changes against the running node:

```bash
topf apply --dry-run
```

This contacts the node without applying changes and redacts secrets in the diff
by default. Exit code `2` means configuration changes were found.

After reviewing the diff, explicitly apply the changes:

```bash
topf apply
```

Topf asks for confirmation before applying.

## Client configuration

Generate a local Talos client configuration from the existing secrets bundle:

```bash
topf talosconfig > talosconfig
chmod 600 talosconfig
export TALOSCONFIG="$PWD/talosconfig"
talosctl --nodes 192.168.1.16 version
```

Topf manages its own client from the secrets bundle; it does not require copying
this file into `~/.talos/config`. To generate an admin kubeconfig (valid for 12
hours by default):

```bash
topf kubeconfig > kubeconfig
chmod 600 kubeconfig
```

## Upgrades

For a Talos upgrade, change `talosVersion` in `topf.yaml`, render and validate,
then review and run:

```bash
topf upgrade --dry-run
topf upgrade
```

When changing system extensions, edit `schematic.yaml` and register the new
schematic with `topf render --submit-to-factory` before upgrading. The current
schematic is already registered.

For a Kubernetes upgrade, change `kubernetesVersion` in `topf.yaml` and follow the
[Talos Kubernetes upgrade guide](https://docs.siderolabs.com/kubernetes-guides/advanced-guides/upgrading-kubernetes).
For the current configured version:

```bash
talosctl --nodes 192.168.1.16 upgrade-k8s --to 1.36.4
```

## New bare-metal installation

For a new cluster only: prepare and boot the Talos image with the configured
schematic and version. Configure the inventory, patches, and encrypted secrets
for that cluster, then render and validate before running:

```bash
topf apply --auto-bootstrap
```

Keep static IP leases configured on the router. Do not bootstrap or generate new
secrets for the existing cluster during routine configuration changes.

## Inspecting the node

```bash
talosctl --nodes 192.168.1.16 disks
talosctl --nodes 192.168.1.16 get manifests
talosctl --nodes 192.168.1.16 dmesg -f
```
