# CoreDNS

1. Go to https://www.hostinger.com/
2. Add a child nameserver pointing to your public IP
3. Set up DNS records to point to your child nameserver
4. Expose coreDNS via NodePort
5. Expose coreDNS publicly by setting NAT in router settings with NAT loopback (so it works from the same network as
   well)
6. Add NS record for ns.dns.blarc.my.id and A record for blarc.my.id manually into ETCD.
   ```bash
   k exec -n etcd -it etcd-0 -- /bin/bash
   export ETCDCTL_ENDPOINTS=http://localhost:2379
   export ETCDCTL_API=3
   etcdctl put /blarcdns/id/my/blarc/dns/ns '{"host": "${public-ip}"}'
   etcdctl put /blarcdns/id/my/blarc/dns/ns2 '{"host": "${public-ip}"}'
   etcdctl put /blarcdns/id/my/blarc '{"host":"ns.dns.blarc.my.id"}'
   etcdctl put /blarcdns/id/my/blarc/_acme-challenge '{"text":"dummy-value"}'
   ```

