# Aurral

[Aurral](https://github.com/lklynet/aurral) provides music discovery, downloads,
and playback. This chart uses app-template 5.3.0 and the stable 2.11.0 image.
The internal route is `https://aurral.blarc.my.id`, with native Authelia OIDC
sign-in and local account authentication available.

## Storage

A retained 5Gi local PVC at `/config` holds the database, settings, artwork,
and download staging. Increase it if staging large downloads requires more space.
The existing `qbittorrent-media` claim is mounted at `/media`, matching Lidarr
and the other media applications. The existing music library is at `/media/music`.
The process runs as UID/GID 1000.
The deployment uses Recreate to avoid overlapping instances on the SQLite database.

## First run

1. Open the internal URL and create the administrator account.
2. Add `/media/music` under Settings > Library files > Read-only folders to
   index and play the existing music in place. If connecting Lidarr instead,
   Aurral can index its `/media/music` root folder through that integration.
3. Use `/media/downloads/aurral` as the Downloads Folder for new Aurral downloads.
   This is seeded by
   `DOWNLOAD_FOLDER`; later changes belong in the web UI.
4. Optionally connect Lidarr at `http://lidarr.media.svc.cluster.local:80`,
   using its API key. Its library is available at `/media/music`.
5. Run Aurral's storage checks and configure the desired download sources and
   playback integrations in the UI. Credentials entered there persist on `/config`.

Direct slskd integration additionally requires allowing Aurral's pods in the
slskd chart's HTTP NetworkPolicy; its current policy only permits Traefik,
DroppedNeedle, and Lidarr. No integration credentials are embedded in this chart.

See the upstream [setup guide](https://docs.aurral.org/getting-started/docker/)
and [filesystem guide](https://docs.aurral.org/getting-started/storage/).

## OIDC (Authelia)

OIDC is configured through GitOps using Aurral's environment variables and the
`aurral` client in the Authelia chart. The issuer is `https://auth.blarc.my.id`
and the callback is `https://aurral.blarc.my.id/sso/callback`. Both sides use
`client_secret_post`, with S256 PKCE required by Authelia.

The raw client secret is SOPS-encrypted in this chart's `values.encrypted.yaml`
and rendered as Secret `aurral-oidc`. Authelia's encrypted values hold its matching
PBKDF2 hash in `authelia-oidc`. Deploy both chart changes before using SSO;
no OIDC settings need to be entered in the Aurral UI.

Any Authelia user can sign in with one-factor authentication and receives the
`user` role by default. `OIDC_ADMIN_USERS: jakob` grants the Authelia user `jakob`
administrator access. Add more comma-separated Authelia usernames to that value
as needed. Aurral recalculates OIDC roles at sign-in.

For an existing local account, sign in locally and link SSO from the account
settings before signing in through SSO separately; matching usernames alone do
not automatically link accounts. The local administrator remains available.
