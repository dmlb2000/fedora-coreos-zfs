# Fedora CoreOS and ZFS

This repository is a set of scripts I use to manage installing ZFS on Fedora CoreOS.

This does prevent the standard updates from Zincati from applying automagically.
The ZFS kernel module tends to lock in the kernel installed and rpm-ostree can't
get around that.

So to properly update the system you'll need to stop using your ZFS and uninstall
the packages to get an upgrade. This means a couple of reboots before you are back
in business.

```
rpm-ostree remove libzfs5 zfs python3-pyzfs zfs-dracut libzpool5 libnvpair3 libuutil3 kmod-zfs-`uname -r`
reboot
# wait for zincati to apply the OS upgrade
/path/to/install-zfs.sh
```
