# Call Of Duty 2 Server

```bash
podman build . -f Dockerfile -t registry.int.blarc.my.id/cod2
```

```bash
podman push registry.int.blarc.my.id/cod2:latest
```

```bash
podman run -d --name cod2-server \
  -p 20500:20500/udp \
  -p 20510:20510/udp \
  -p 28960:28960/tcp \
  -p 28960:28960/udp \
  localhost/cod2:latest \
  +set net_port 28960 \
  +set sv_cheats 0 \
  +set sv_punkbuster 0 \
  +exec punkbuster.cfg \
  +exec server_mp.cfg
```
