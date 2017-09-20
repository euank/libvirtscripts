#!/bin/bash

set -x
set -e

. ./util/lib.sh

NAME="k8s-$(name::random_name)"
internal_ip="${1:?Internal IP}"

MEMORY=4096
DISK_IMAGE=$(image::latest_coreos_alpha_path)

DISK_BASE=/mnt/gold/virts/disks
DISK="${DISK_BASE}/${NAME}.raw"

internal_mac=$(name::random_mac)

virsh net-update --network "internal" add-last ip-dhcp-host \
    --xml "<host mac='${internal_mac}' ip='${internal_ip}' />" \
    --live --config

sleep 5

qemu-img convert "${DISK_IMAGE}" -O raw "${DISK}"
qemu-img resize "${DISK}" 50G

domain_file="${DISK}.domain.xml"
virt-install --virt-type=kvm \
             --connect "qemu:///system" \
	     --memory ${MEMORY} \
	     -n "${NAME}" \
	     --vcpus 4 \
	     -v \
	     --os-variant=virtio26 \
	     --os-type linux \
	     --disk path="${DISK}",device=disk,bus=virtio,format=raw \
	     --boot=hd --network network=default,model=virtio \
	     --graphics=none \
	     --noautoconsole \
	     --network bridge=virbr1,model=virtio,mac="${internal_mac}" \
	     --print-xml > "${domain_file}"

template_config="${DISK}.ign.config"
ignition_file="${DISK}.ign"

cat > "${template_config}" <<EOF
kubeletVersion: v1.6.8_coreos.0
k8sCa: |-
$(util::misc::indent "$(util::certs::get_ca)" 2)
internalIP: "${internal_ip}"
flannelEtcdEndpoints: "${FLANNELD_ETCD_ENDPOINTS}"
bootstrapToken: "${SECRET_BOOTSTRAP_TOKEN}"
hostname: "${NAME}.k8s.euank.com"
EOF

./bin/sprig -f "${template_config}" "./clcs/k8s-worker.clt.tmpl" > "${ignition_file}.yaml"
./bin/ct < "${ignition_file}.yaml" > "${ignition_file}"

libvirt::domain::add_ignition "${domain_file}" "${ignition_file}"

virsh define "${domain_file}"
virsh start "${NAME}"
