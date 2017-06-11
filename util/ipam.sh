# Meant to be sourced as util functions

function ipam::get_free_mac() {
  sort <(cat map.txt | awk '{print $1}' && cat taken.txt | awk '{print $1}') | uniq -u | head -n 1
}

function ipam::add_taken() {
  name=${1:?Must have name arg}
  mac=${2:?Must have mac arg}
  ip=$(ipam::get_ip "${mac}")
  echo "${mac} ${ip} ${name}" >> taken.txt
}

function ipam::remove_taken() {
  name=${1:?Must have name arg}
  sed -r -i "/\\s+${name}\$/d" taken.txt
}

function ipam::get_ip_by_name() {
  name=${1:?Must have name arg}
  ip=$(cat taken.txt | grep -E " ${name}$" | awk '{print $2}')
  if [[ -z "${ip}" ]]; then
    echo "No mapping found for ${mac}"
    exit 1
  fi
  echo "$ip"
}

function ipam::get_ip() {
  mac=${1:?Must have mac arg}
  ip=$(cat map.txt | grep -E "^${mac}" | awk '{print $2}')
  if [[ -z "${ip}" ]]; then
    echo "No mapping found for ${mac}"
    exit 1
  fi
  echo "$ip"
}
