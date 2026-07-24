# Docker Mailserver

User was added by executing into the pod and creating one via cli.


## Why Load Balancer
Some services, for example lldap, can not ignore certificate like audiobookshelf can.
This means we need to expose the mailserver on the DNS for which certificate is created.
For that, we need a static IP and therefore a LB.