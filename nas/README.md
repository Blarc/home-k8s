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

### Disk monitoring and scheduled checks

Deploy from `nas/`, then deploy the VictoriaMetrics, Grafana and ntfy changes through Argo CD:

```bash
ansible-playbook -i inventory.ini playbooks/setup_metrics.yaml --ask-become-pass
```

Uses [prometheus-smart-collector](https://github.com/jgeboski/prometheus-smart-collector) through
node exporter and [zfs_exporter](https://github.com/pdf/zfs_exporter). SMART attributes refresh every
15 minutes; metrics are retained for seven days.

Schedules use Europe/Ljubljana time:

- HDD short tests: daily during 04:00–04:59.
- HDD long tests: monthly on days 1, 2 and 3 during 01:00–01:59, as assigned in `setup_metrics.yaml`.
- ZFS scrub: existing schedule, second Sunday monthly at 00:24.

Grafana: **NAS → NAS disk attributes and pool health**. Alertmanager sends ntfy notifications for
faults and recoveries: warning priority 4, critical priority 5, recovery priority 2.

The collectors do not report individual test or scrub results, so successful checks produce no
notification. Missing SMART data can indicate a health warning. Independent backups remain necessary.

When replacing a disk, update its by-id entry in `setup_metrics.yaml` and the expected serials in
the VictoriaMetrics rules and Grafana dashboard.

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
