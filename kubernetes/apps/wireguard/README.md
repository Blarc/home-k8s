# Wireguard

1. Router needs to open the correct port for the NodePort service (`Advanced Setup > NAT`):

   | Server Name | External Port Start | External Port End | Protocol | Internal Port Start | Internal Port End | Server IP Address | NAT Loopback |
   |-------------|---------------------|-------------------|----------|---------------------|-------------------|-------------------|--------------|
   | wireguard   | 31820               | 31820             | UDP      | 31820               | 31820             | 192.168.1.16      | enabled      |

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
kubectl get secret wireguard-peer-configs -o jsonpath='{.data.blarc}' | base64 -d
```

QR code:

```bash
kubectl get secret wireguard-peer-configs -o jsonpath='{.data.blarc}' | base64 -d | qrencode -t ansiutf8
```

## Address and LoadBalancer IP are different

When using wireguard CRD with `spec.serviceType: LoadBalancer`, keep in mind that Wireguard operator will try to set the
external IP of the Load Balancer service to the one specified in crd under property `spec.address`.

In my case this didn't work, because I set `spec.address` to my public IP, while the Load Balancer service IP should be
set to an IP from the range of the IP pool. I had to manually change the Load Balancer service IP by editing the
resource to get the wireguard working. This is the reason I changed the service type to NodePort instead.
