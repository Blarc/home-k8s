# CoreDNS

CoreDNS is used as authoritative (and not recursive) DNS server for domain `blarc.my.id`. This means, it will only
resolve the subdomains for domain `blarc.my.id`. This works because the DNS is publicly available, and we use some other
recursive resolver as our main resolver.

## ETCD

For storing the records, we use ETCD instead of zone files (not 100% if that's what they're called). This is enabled via
builtin CoreDNS plugin called `etcd`. In order for this to work, we need an instance of ETCD running and configure the
plugin with the correct endpoint and path. The path can be set to anything, it just specifies the path at which the
records will be saved in ETCD.

## How to set up

1. Expose CoreDNS via LoadBalancer (or NodePort)
2. Expose CoreDNS publicly by setting NAT (`Advanced Setup > NAT`) in router settings with NAT loopback (so it works from the same network as
   well)

   | Server Name | External Port Start | External Port End | Protocol | Internal Port Start | Internal Port End | Server IP Address | NAT Loopback |
   |-------------|---------------------|-------------------|----------|---------------------|-------------------|-------------------|--------------|
   | coredns     | 53                  | 53                | TCP      | 53                  | 53                | 192.168.1.221     | enabled      |       
   | coredns     | 53                  | 53                | UDP      | 53                  | 53                | 192.168.1.221     | enabled      | 

3. Add initial records manually, by inserting them into ETCD:
   ```bash
   k exec -n etcd -it etcd-0 -- /bin/bash
   export ETCDCTL_ENDPOINTS=http://localhost:2379
   export ETCDCTL_API=3
   etcdctl put /blarcdns/id/my/blarc/dns/ns '{"host": "${public-ip}"}'
   etcdctl put /blarcdns/id/my/blarc/dns/ns2 '{"host": "${public-ip}"}'
   etcdctl put /blarcdns/id/my/blarc '{"host":"ns.dns.blarc.my.id"}'
   etcdctl put /blarcdns/id/my/blarc/_acme-challenge '{"text":"dummy-value"}'
   ```
4. Set up DNS records to point to your child nameserver
5. Go to https://www.hostinger.com/
6. Add a child nameserver pointing to your public IP
7. Commands `dig blarc.my.id SOA` and `host ns.dns.blarc.my.id` should work.

## DNSSEC

Unfortunately, my domain's TLD does not support DNSSEC. But here's how to set it up:

Sources:

1. https://www.icann.org/resources/pages/dnssec-what-is-it-why-important-2019-03-05-en
2. https://coredns.io/plugins/dnssec/

### How to:

1. Install a package providing dnssec-keygen command:
   ```bash
   sudo dnf install bind-dnssec-utils
   ```
2. Generate a public and private key pair:
   ```bash
   # cd to coredns/dnssec
   dnssec-keygen -a ECDSAP256SHA256 blarc.my.id
   ```
3. Mount the key pair to CoreDNS via secret and configure the plugin `dnssec` in `values.yaml`.
4. Configure TLD.
