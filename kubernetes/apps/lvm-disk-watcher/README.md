# Lvm Disk Watcher

https://github.com/truecharts/public/blob/master/containers/apps/lvm-disk-watcher/includes/watch_lvm.sh

- This creates volume group.
- The disk needs to be empty - meaning no user volumes defined.
- All pvc that maybe used the disk previously need to be deleted.

Fails when trying to create thin volume?
```bash
kubectl exec -it -n lvm-disk-watcher lvm-disk-watcher-tmlbt -- /bin/bash
lvcreate -l 100%FREE --chunksize 256 -T -A n -n topolvm_thin topolvm_vg
```
```log
Configuration found for node worker-1: all
All disks configured for node worker-1.
Disk /dev/sda has no partitions. Checking for LVM and filesystem signatures.
Disk /dev/sda is empty and has no LVM or filesystem signatures. Setting up LVM.
  Labels on physical volume "/dev/sda" successfully wiped.
/dev/sda: 8 bytes were erased at offset 0x00000200 (gpt): 45 46 49 20 50 41 52 54
/dev/sda: 8 bytes were erased at offset 0x773c255e00 (gpt): 45 46 49 20 50 41 52 54
/dev/sda: 2 bytes were erased at offset 0x000001fe (PMBR): 55 aa
/dev/sda: calling ioctl to re-read partition table: No error information
  Physical volume "/dev/sda" successfully created.
  Volume group "topolvm_vg" successfully created
modprobe: can't change directory to '/lib/modules': No such file or directory
  /sbin/modprobe failed: 1
  thin-pool: Required device-mapper target(s) not detected in your kernel.
  Run `lvcreate --help' for more information.
```
THIS CAN BE SOLVED BY ADDING KERNEL MODULES VIA TALCONFIG
```yaml
kernelModules:
  - name: dm_thin_pool
  - name: dm_mod
```
