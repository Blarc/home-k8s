# Docker Mailserver

To add user, generate password and add it to a config map:
```bash
kubectl -n docker-mailserver exec -it deployment/docker-mailserver -- doveadm pw -s SHA512-CRYPT
```


## Why Load Balancer
Some services, for example lldap, can not ignore certificate like audiobookshelf can.
This means we need to expose the mailserver on the DNS for which certificate is created.
For that, we need a static IP and therefore a LB.