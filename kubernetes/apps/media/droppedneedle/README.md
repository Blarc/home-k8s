# DroppedNeedle

[DroppedNeedle](https://github.com/DroppedNeedle/DroppedNeedle) provides music
requests, discovery, and library management. This chart uses app-template 5.3.0
and exposes the application through the internal gateway at
`https://droppedneedle.blarc.my.id`.

## Storage

Config and database (`/app/config`), cache (`/app/cache`), plugins (`/app/plugins`),
and drop imports (`/app/imports`) use separate retained local PVCs. The existing
`qbittorrent-media` claim is mounted at `/media`, keeping the music library and
completed downloads on one filesystem. The app runs as UID/GID 1000 with umask
002 for shared media access.

## First run

1. Open the application and create the first administrator account.
2. Set the library path to `/media/music` under Settings > Library.
3. Configure slskd under Settings > Download Client using
   `http://slskd.media.svc.cluster.local:80` and the API key described in
   [the slskd README](../slskd/README.md#droppedneedle).
   This chart does not deploy the client. qBittorrent is not a supported
   download client for DroppedNeedle.
4. Make the client's completed downloads accessible under `/media`. For slskd,
   this chart sets `SLSKD_DOWNLOADS_PATH=/media/slskd/complete`; adjust the value
   to match the actual completed-download directory. For SABnzbd, configure its
   Downloads path in the UI using the corresponding in-container path.
5. Configure indexers/Prowlarr in the UI if using Usenet, then scan the library.

Settings and credentials entered in the UI persist on the config volume.
The chart does not overwrite them on restart.

## OIDC (Authelia)

Authelia registers the `droppedneedle` client with one-factor authentication and
implicit consent. Any Authelia user can sign in; new OIDC accounts receive the
User role and can be promoted under Settings > Users.

DroppedNeedle configures OIDC through its UI rather than environment variables
([upstream instructions](https://github.com/DroppedNeedle/DroppedNeedle#configuration)).
After deploying both charts, sign in with the local administrator account, open
Settings > Security, and enable OIDC with:

| Setting       | Value                                                         |
|---------------|---------------------------------------------------------------|
| Issuer URL    | `https://auth.blarc.my.id`                                    |
| Client ID     | `droppedneedle`                                               |
| Client Secret | Decrypt the value below                                       |
| Redirect URI  | `https://droppedneedle.blarc.my.id/api/v1/auth/oidc/callback` |
| Scopes        | `openid profile email`                                        |

The raw client secret is SOPS-encrypted in this chart's `values.encrypted.yaml`
and rendered as Secret `droppedneedle-oidc`. Authelia stores its hashed counterpart.
From the repository root on macOS, copy the raw secret directly to the clipboard:

```sh
sops decrypt --extract '["app-template"]["secrets"]["oidc"]["stringData"]["client-secret"]' kubernetes/apps/media/droppedneedle/values.encrypted.yaml | pbcopy
```

Save the settings, then verify the SSO button in a private browser session.
Keep local administrator login available until OIDC login has been verified.
The OIDC settings persist on the config PVC.

The startup probe allows ten minutes for database migrations before liveness
checks begin. The image is pinned by digest; update the digest to upgrade it.
