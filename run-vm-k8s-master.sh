#!/bin/bash

set -x
set -e

. ./util/lib.sh

NAME="k8s-master-$(name::random_name)"

if `grep "${NAME}$" taken.txt`; then
  echo "try again"
  exit 1
fi

MEMORY=2048
DISK_IMAGE=$(image::latest_coreos_stable_path)

DISK_BASE=/mnt/gold/virts/disks
DISK="${DISK_BASE}/${NAME}.raw"

mac=$(ipam::get_free_mac)
internal_mac=$(name::random_mac)

if [[ -z "${mac}" ]]; then
  echo "No mac get"
  exit 1
fi

ip=$(ipam::get_ip $mac)
last_quad=$(echo $ip | grep -Eo "[0-9]+$")

internal_ip=$(echo "192.168.131.${last_quad}")
virsh net-update --network "internal" add-last ip-dhcp-host \
    --xml "<host mac='${internal_mac}' ip='${internal_ip}' />" \
    --live --config

sleep 3

qemu-img convert "${DISK_IMAGE}" -O raw "${DISK}"
qemu-img resize "${DISK}" 40G

domain_file="${DISK}.domain.xml"
virt-install \
  --virt-type=kvm \
  --connect "qemu:///system" \
  --memory ${MEMORY} \
  -n "${NAME}" \
  --vcpus 4 \
  -v --os-variant=virtio26 \
  --os-type linux \
  --disk path="${DISK}",device=disk,bus=virtio,format=raw \
  --boot=hd \
  --network type=direct,source=enp3s0,source_mode=bridge,mac="${mac}",model=virtio \
  --network bridge=virbr1,model=virtio,mac="${internal_mac}" \
  --graphics=none \
  --noautoconsole \
  --print-xml > "${domain_file}"

template_config="${DISK}.ign.config"
ignition_file="${DISK}.ign"

cat > "${template_config}" <<EOF
k8sCa: |-
$(util::misc::indent "$(util::certs::get_ca)" 2)
k8sCaRoot: |-
$(util::misc::indent "$(util::certs::get_ca_root)" 2)
k8sCaKey: |-
$(util::misc::indent "$(util::certs::get_ca_key)" 2)
k8sApiserverPem: |-
$(util::misc::indent "$(util::certs::get_apiserver_pem)" 2)
k8sApiserverKey: |-
$(util::misc::indent "$(util::certs::get_apiserver_key)" 2)
k8sControllerPem: |-
$(util::misc::indent "$(util::certs::get_controller_pem)" 2)
k8sControllerKey: |-
$(util::misc::indent "$(util::certs::get_controller_key)" 2)
k8sSchedulerPem: |-
$(util::misc::indent "$(util::certs::get_scheduler_pem)" 2)
k8sSchedulerKey: |-
$(util::misc::indent "$(util::certs::get_scheduler_key)" 2)
internalIP: "${internal_ip}"
flannelEtcdEndpoints: "${FLANNELD_ETCD_ENDPOINTS}"
bootstrapToken: "${SECRET_BOOTSTRAP_TOKEN}"
hostname: "${NAME}.k8s.euank.com"
kubeletVersion: 1.8.6
kubeletHash: "776faf94a668d4923b0b011262d965273e467482e62eba7446a4df6cdb9f8976fb6ca9b4c17b3484f26c349a21aeccc867e1602a0d8675ac52bd78385b3ce443"
EOF

./bin/sprig -f "${template_config}" "./clcs/k8s-master.clt.tmpl" > "${ignition_file}.yaml"
./bin/ct < "${ignition_file}.yaml" > "${ignition_file}"

libvirt::domain::add_ignition "${domain_file}" "${ignition_file}"

ipam::add_taken "$NAME" "$mac"

virsh define "${domain_file}"
virsh start "${NAME}"
