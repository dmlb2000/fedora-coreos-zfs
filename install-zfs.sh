#!/bin/bash -xe

if ! [ -e /usr/sbin/zfs ] ; then
  if [[ $(podman ps -aqf name=buildzfs) ]] ; then
    podman stop buildzfs
    podman rm buildzfs
  fi
  podman run -d --name=buildzfs -v /root:/root --privileged --rm fedora:$(sed 's/.*release \([0-9]*\) .*/\1/' /etc/redhat-release) /bin/bash -c 'while true ; do sleep 1; done'
  podman exec buildzfs dnf -y install libtirpc-devel systemd-devel libaio-devel libblkid-devel libuuid-devel make gcc pkgconfig koji tar gzip file rpm-build ncompress python3 python3-devel python3-cffi python3-packaging python3-setuptools libattr-devel libffi-devel
  BUILDDIR=$(podman exec buildzfs mktemp -d)
  ZFS_VER="2.1.4"
  KERNEL_VER=$(uname -r | sed 's/\.x86_64//')
  podman exec -w $BUILDDIR buildzfs koji download-build --arch=x86_64 kernel-"${KERNEL_VER}"
  podman exec -w $BUILDDIR buildzfs /bin/sh -c 'rm *debug*.rpm'
  podman exec -w $BUILDDIR buildzfs /bin/sh -c 'dnf -y install *.rpm'
  podman exec -w $BUILDDIR buildzfs /bin/sh -c 'curl -Lo - https://github.com/openzfs/zfs/releases/download/zfs-'${ZFS_VER}'/zfs-'${ZFS_VER}'.tar.gz | tar -xzf -'
  podman exec -w $BUILDDIR/zfs-${ZFS_VER} buildzfs /bin/sh -c './configure --prefix=/usr --with-linux="/lib/modules/'${KERNEL_VER}'.x86_64/build" && make rpm'
  podman exec -w $BUILDDIR/zfs-${ZFS_VER} buildzfs /bin/sh -c 'rm -f *debug*.rpm *.src.rpm *test*.rpm *devel*.rpm *dkms*.rpm'
  podman exec -w $BUILDDIR/zfs-${ZFS_VER} buildzfs /bin/sh -c 'tar -czf /root/zfs-'${ZFS_VER}'-'${KERNEL_VER}'.x86_64-install.tar.gz *.rpm'
  podman stop buildzfs
  tar -C /tmp -xzf /root/zfs-${ZFS_VER}-${KERNEL_VER}.x86_64-install.tar.gz
  rpm-ostree install /tmp/*.rpm
  rm /root/zfs-${ZFS_VER}-${KERNEL_VER}.x86_64-install.tar.gz /tmp/*.rpm
  reboot
fi
systemctl start zfs-mount
setsebool -P container_manage_cgroup true
