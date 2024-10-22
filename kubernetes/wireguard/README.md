# Wireguard

1. Router needs to open the correct port for the correct IP.
2. Configuration is saved on the node. In order to delete configuration you need to execute to pod and delete with:
   ```bash
   rm -rf /config # Can't delete the folder, but deletes it's contents which is good enough
   ```
3. If the routers static IP changes, `SERVERURL` environment variable, that is mapped from secret, needs to be updated.

## Setting up Wireguard on PC

In Wireguard on PC, right-click your tunnel, Edit Selected Tunnel, then in the Peer section for AllowedIPs, add
your specific subnet first before 0.0.0.0/0. For example, mine looks like this:

```
[Peer]
...
AllowedIPs = 192.168.1.0/24, 0.0.0.0/0
```

This is because there are already routing tables set up on your machine that have a higher priority, so while local
subnet traffic can route through the wireguard path it will not because of the route priority. By adding this it
basically sets the wireguard route as the highest priority for that specific subnet.

## Installing with kustomize
Make sure you have [kustomize](https://kustomize.io/) na [KSOPS](https://github.com/viaduct-ai/kustomize-sops) installed
and run the following command:
```bash
# Change the . to path if you're not running from wireguard folder
kustomize build --enable-alpha-plugins --enable-exec . | kubectl apply -f -
```
