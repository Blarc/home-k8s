```bash
ansible-playbook -i inventory.ini playbooks/setup_zfs.yaml --ask-become-pass
```

Install dufs and serve the NAS `/storage` directory on port 5000:

```bash
ansible-playbook -i inventory.ini playbooks/setup_dufs.yaml --ask-become-pass
```

Browser access through `https://nas.blarc.my.id` is authenticated by Authelia at the Traefik gateway. The dufs playbook
restricts direct access to NAS port 5000 to localhost and the Kubernetes node at `192.168.1.16`. Sync the Authelia
policy and protected HTTPRoute before running this playbook; the playbook starts the firewall before it removes the dufs
password.

## Tasks

### Ensure contrib and non-free repositories are enabled

Debian is committed to Free Software. ZFS is licensed under the CDDL, which is considered "non-free" by Debian's
standards. Therefore, the ZFS packages aren't in the default main repository.
What it does: It adds the contrib component to your /etc/apt/sources.list. The {{ ansible_distribution_release }}
variable automatically detects if you are on bookworm, bullseye, etc.

### Install Linux headers and ZFS packages

Because of licensing, Debian cannot ship the ZFS driver pre-compiled into the kernel. Instead, it uses DKMS (Dynamic
Kernel Module Support).
The components:

- linux-headers-...: These are the "blueprints" of your current kernel. DKMS needs these to build the ZFS driver
  specifically for your system.
- zfs-dkms: This is the source code for the ZFS driver. Once downloaded, your server will automatically start "
  compiling" the driver (this task might take a few minutes).
- zfsutils-linux: These are the command-line tools (zpool, zfs) you'll use to manage your disks.
