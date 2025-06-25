# Wireguard

1. Router needs to open the correct port for the LoadBalancer's IP (`Advanced Setup > NAT`):

   | Server Name | External Port Start | External Port End | Protocol | Internal Port Start | Internal Port End | Server IP Address | NAT Loopback |
   |-------------|---------------------|-------------------|----------|---------------------|-------------------|-------------------|--------------|
   | wireguard   | 51820               | 51820             | UDP      | 51820               | 51820             | 192.168.1.222     | enabled      |

2. If the router's static IP changes property `spec.address` needs to be updated.

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

## Retrieving the peer configuration
Plain text:
```bash
kubectl get wireguardpeer -n wireguard blarc --template={{.status.config}} | bash
```
QR code:
```bash
kubectl get wireguardpeer -n wireguard blarc --template={{.status.config}} | bash | qrencode -t ansiutf8
```

