
ROOT="$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )/.."

source "${ROOT}/config.sh"
source "${ROOT}/util/misc.sh"
source "${ROOT}/util/libvirt/domain.sh"
source "${ROOT}/util/certs.sh"
source "${ROOT}/util/name.sh"
source "${ROOT}/util/ipam.sh"
source "${ROOT}/util/userdata.sh"
source "${ROOT}/util/k8s.sh"
source "${ROOT}/util/image.sh"
