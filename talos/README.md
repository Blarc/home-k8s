# Talos

## Bare-metal installation
1. Download ISO from: https://github.com/siderolabs/talos/releases (look for metal-*)
2. Run `mediawriter` if on Fedora.
3. Plug to PC and boot from USB.
4. Apply config:
   ```bash
   talosctl apply-config --nodes=192.168.1.17 --file=./clusterconfig/home-control-plane-1.yaml --insecure
   ```
5. Bootstrap the control plane:
   ```bash
   talosctl bootstrap --nodes 192.168.1.17 --endpoints 192.168.1.17 --talosconfig=./clusterconfig/talosconfig
   ```
6. Retrieve kubeconfig:
   ```bash
   talosctl kubeconfig -n 192.168.1.17
   ```

## Static IP for nodes
To prevent changing of nodes' IP, set static IPs for the nodes on the router (Advanced setup > Lan > Static IP Lease List)

## Talosctl

Talos uses CLI called talosctl to interact with the cluster. The configuration works similarly as for kubernetes. The configuration file is located at `~/.talos/config`.

To check the version of nodes, you can run the following command:
```bash
talosctl version # assumes talosctl config is configured properly
```
To check disks:
```bash
talosctl -e 192.168.1.17 disks
```
It's important the correct disk is specified in the machine config. You can edit machine config with:
```bash
TALOS_EDITOR="vim" talosctl edit machineconfig -n 192.168.1.17
```

## Upgrading Talos nodes
Docs: https://docs.siderolabs.com/talos/v1.8/configure-your-talos-cluster/lifecycle-management/upgrading-talos.

Run the following command for each node
```bash
talosctl upgrade --nodes 192.168.1.17 --endpoints 192.168.1.17 --image <copy-from-machine-configuration>
```
To watch the upgrade logs use:
```bash
talosctl dmesg -f
```
and optionally:
```bash
talosctl upgrade --wait --debug
```

## Upgrading Kubernetes
Docs: https://docs.siderolabs.com/kubernetes-guides/advanced-guides/upgrading-kubernetes.

Run the following command
```bash
talosctl --nodes 192.168.1.17 upgrade-k8s --to 1.34.0
```

## Inspecting manifests of static pods
Run the following command to list manifests of static pods for specific node:
```bash
talosctl get manifests -n 192.168.1.17
```

## Talhelper
https://budimanjojo.github.io/talhelper/latest/getting-started/ \
Talhelper is kustomize for Talos. It helps you configure Talos machine configuration in a GitOps way.
It uses `talconfig.yaml`, which defines all the configuration and `talsecret.sops.yaml` that contains the Talos cluster's
secrets and certificates. To generate the machine configuration, run the following command:
```bash
cd talos
talhelper genconfig
```
This generates machine configuration and `talosconfig` which is used to connect to your Talos cluster. To use the config,
copy it to `~/.talos/config`. You can then apply the configuration to each node:
```bash
# Add --insecure flag, if the cluster is new
talosctl apply-config --nodes=192.168.1.16 --file=./clusterconfig/home-multi-role.yaml
```

