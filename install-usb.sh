#!/bin/bash -xe
FILE=${1:-server}
test -f "${FILE}.ign"
sudo podman run --pull=always --privileged --rm \
    -v /dev:/dev -v /run/udev:/run/udev -v .:/data -w /data \
    quay.io/coreos/coreos-installer:release \
    install /dev/sdb -i "${FILE}.ign"
