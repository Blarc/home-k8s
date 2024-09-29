# Talos

## Static IP for nodes
To prevent changing of nodes' IP, set static IPs for the nodes on the router (Advanced setup > Lan > Static IP Lease List)

## Talosctl

Talos uses CLI called talosctl to interact with the cluster. The configuration works similar as for kubernetes. The configuration file is located at `~/.talos/config`.

To check the version of nodes, you can run the following command:
```bash
talosctl version # assumes talosctl config is configured properly
```
To check disks:
```bash
talosctl -e 192.168.1.17 disks
```
It's important correct disk is specified in the machine config. You can edit machine config with:
```bash
TALOS_EDITOR="vim" talosctl edit machineconfig -e 192.168.1.17
```

## Upgrading Talos nodes
Docs: https://www.talos.dev/v1.8/talos-guides/upgrading-talos/.

Run the following command for each node
```bash
talosctl upgrade --nodes 192.168.1.17 --endpoints 192.168.1.17 --image ghcr.io/siderolabs/installer:v1.8.0 --preserve=true
```
For a **single-node** control-plane, make sure that `--preserve=true`.
