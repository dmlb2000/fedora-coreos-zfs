#!/bin/bash -xe

if ! [ -e /usr/bin/ansible-playbook ] ; then
    rpm-ostree install ansible dnf-plugins-core vim strace iotop fail2ban git htop lm_sensors screen buildah python3-virtualenv python3-setuptools python3-dnf
    reboot
fi
