#!/bin/bash

set -x
set -e

. ./util/lib.sh

NAME="k8s-$(name::random_name)"
internal_ip="$(ipam::get_internal_ip)"

MEMORY=8192
DISK_IMAGE=$(image::latest_coreos_stable_path)

DISK_BASE=/mnt/gold/virts/disks
DISK="${DISK_BASE}/${NAME}.raw"

internal_mac=$(name::random_mac)

ipam::mark_taken_internal_ip "${NAME}" "${internal_ip}"
virsh net-update --network "internal" add-last ip-dhcp-host \
    --xml "<host mac='${internal_mac}' ip='${internal_ip}' />" \
    --live --config

sleep 5

qemu-img convert "${DISK_IMAGE}" -O raw "${DISK}"
qemu-img resize "${DISK}" 50G

domain_file="${DISK}.domain.xml"
virt-install \
	--virt-type=kvm \
	--connect "qemu:///system" \
	--memory ${MEMORY} \
	-n "${NAME}" \
	--vcpus 4 \
	-v \
	--os-variant=virtio26 \
	--os-type linux \
	--disk path="${DISK}",device=disk,bus=virtio,format=raw \
	--boot=hd \
        --network network=default,model=virtio \
	--graphics=none \
	--noautoconsole \
	--network bridge=virbr1,model=virtio,mac="${internal_mac}" \
	--print-xml > "${domain_file}"

template_config="${DISK}.ign.config"
ignition_file="${DISK}.ign"

cat > "${template_config}" <<EOF
kubeletVersion: 1.11.1
kubeletHash: "bba0dd504eda8b1ac7068a440c557c9e6277bfb16da534ce748c5144abbea1b9e70e9902154daf092a67a4b468e9b9d2549436968774e90d60c4143cf169451d"
k8sCa: |-
$(util::misc::indent "$(util::certs::get_ca)" 2)
internalIP: "${internal_ip}"
bootstrapToken: "${SECRET_BOOTSTRAP_TOKEN}"
hostname: "${NAME}.k8s.euank.com"
EOF

./bin/sprig -f "${template_config}" "./clcs/k8s-worker.clt.tmpl" > "${ignition_file}.yaml"
./bin/ct < "${ignition_file}.yaml" > "${ignition_file}"

libvirt::domain::add_ignition "${domain_file}" "${ignition_file}"

virsh define "${domain_file}"
virsh start "${NAME}"
