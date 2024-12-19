# Etcd

Used for storing CoreDNS records.

## TODO
- Add persistence, currently emptyDir is used.

## How to
```bash
kubens etcd
k exec -n etcd -it etcd-0 -- /bin/bash
export ETCDCTL_ENDPOINTS=http://localhost:2379
export ETCDCTL_API=3
etcdctl put /skydns/com/example/www '{"host": "192.168.1.100"}'
etcdctl get /skydns/com/example/www
etcdctl del /skydns/com/example/www
etcdctl get / --prefix
```
