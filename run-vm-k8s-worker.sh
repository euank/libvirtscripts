#!/bin/bash

set -x
set -e

. ./util/lib.sh

NAME="k8s-$(name::random_name)"
MEMORY=2048
DISK_IMAGE=$(image::latest_coreos_stable_path)

DISK_BASE=/mnt/raidb/virts/disks
DISK="${DISK_BASE}/${NAME}.ovl"

qemu-img create -f qcow2 -b "${DISK_IMAGE}" "${DISK}" 40G

mac=$(ipam::get_free_mac)

if [[ -z "${mac}" ]]; then
  echo "No mac get"
  exit 1
fi

ip=$(ipam::get_ip $mac)

userdata_dir=$(userdata::create_k8s "${NAME}" "${ip}")

virt-install --virt-type=kvm --connect "qemu:///system" --memory ${MEMORY} -n "${NAME}" --vcpus 8 -v --os-variant=virtio26 --os-type linux --disk path="${DISK}",device=disk,bus=virtio,format=qcow2,cache="writeback" --boot=hd --network type=direct,source=enp3s0,source_mode=bridge,mac="${mac}",model=virtio --graphics=none --filesystem ${userdata_dir},config-2,type=mount,mode=squash --noautoconsole --network bridge=virbr1,model=virtio

ipam::add_taken "$NAME" "$mac"
