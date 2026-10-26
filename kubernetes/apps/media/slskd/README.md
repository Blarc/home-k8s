# slskd

[slskd](https://github.com/slskd/slskd) runs in the media namespace with an internal
web route at `https://slskd.blarc.my.id`. The app-template dependency is 5.3.0 and
the official container image is pinned by digest.

## Storage and sharing

Application state and `slskd.yml` persist on a 1Gi local PVC mounted at `/app`.
The shared `qbittorrent-media` claim is mounted at `/media`, with these paths:

- Shared music: `/media/music` (visible to Soulseek peers).
- Completed downloads: `/media/slskd/complete`.
- Incomplete downloads: `/media/slskd/incomplete`.

An init container creates these directories as UID/GID 1000. Both containers use
the same identity as DroppedNeedle, with umask 002 for group-writable files.
Completed and incomplete downloads stay on the same filesystem.

## First run

1. Open the internal web URL and sign in through Authelia. There is no separate
   slskd web login.
2. Use the configuration editor to set `soulseek.username` and
   `soulseek.password`. These credentials persist in `/app/slskd.yml`.
3. Forward public **TCP 50300** on the router to TCP 50300 on the peer service's
   assigned LoadBalancer IP. Find it after deployment with:

   ```sh
   kubectl -n media get service slskd-soulseek
   ```

Cilium assigns the peer service an IP from its configured pool. To reserve an
address, add `lbipam.cilium.io/ips` under `service.soulseek.annotations`. The web
service remains internal; TLS terminates at Traefik.

The `--no-auth` command-line argument disables slskd's built-in authentication
and takes precedence over `slskd.yml`. Traefik uses a chart-owned Authelia
forward-auth middleware. A NetworkPolicy restricts HTTP access to Traefik pods
and DroppedNeedle pods in this namespace. TCP 50300 remains open to Soulseek
peers. Authelia explicitly allows `user:jakob` with `one_factor` authentication
for this hostname and denies everyone else.

## DroppedNeedle

Under Settings > Download Client, configure slskd at
`http://slskd.media.svc.cluster.local:80`. Retrieve the API setting locally:

```sh
sops --decrypt --extract '["app-template"]["controllers"]["slskd"]["containers"]["app"]["env"]["SLSKD_API_KEY"]' kubernetes/apps/media/slskd/values.encrypted.yaml
```

Paste only the key after `role=ReadWrite;` into DroppedNeedle. Its configured
`SLSKD_DOWNLOADS_PATH` already matches `/media/slskd/complete`.

The API key remains in SOPS-encrypted values for clients that require a key
setting; slskd does not enforce API authentication with `--no-auth`. DroppedNeedle
connects directly through the HTTP allowance in the NetworkPolicy.

Soulseek credentials can also be managed in encrypted values using `SLSKD_SLSK_USERNAME` and
`SLSKD_SLSK_PASSWORD`; avoid defining conflicting values in `slskd.yml`, which
takes precedence over environment variables.
