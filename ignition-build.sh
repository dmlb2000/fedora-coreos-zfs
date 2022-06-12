#!/bin/bash -xe

podman pull quay.io/coreos/butane:release
podman pull quay.io/coreos/ignition-validate:release
for f in *.bu ; do
  podman run -i --rm quay.io/coreos/butane:release --pretty --strict < ${f} > ${f/.bu/}.ign
done
for f in *.ign ; do
  podman run --rm -i quay.io/coreos/ignition-validate:release - < ${f}
done
