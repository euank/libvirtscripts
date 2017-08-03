source "${ROOT}/util/kv.sh"

function image::update_coreos_image_dir() {
    channel=${1:?channel}
    version=${2:?version}
    url=${3:?url}
    mkdir -p "${IMAGE_ROOT}/coreos"
    IMAGE_FILE="$(image::coreos_path "${channel}" "${version}")"

    if [[ -e "${IMAGE_FILE}" ]]; then
      echo "Image already exists: ${IMAGE_FILE}"
    else
      wget "${url}" -O - | bzcat > "${IMAGE_FILE}"
    fi
}

function image::update_coreos_image() {
  channel=${1:?specify channel}
  if [[ "$channel" != "alpha" && "$channel" != "stable" && "$channel" != "beta" ]]; then
    echo "must specify stable or beta alpha"
    exit 1
  fi
  local version_info=$(curl -s "https://${channel}.release.core-os.net/amd64-usr/current/version.txt")

  eval "$(echo "${version_info}" | grep -E "^COREOS_VERSION=")"
  
  if [[ -z "${COREOS_VERSION}" ]]; then
    echo "Unable to parse version info"
    return 1
  fi

  local url="https://${channel}.release.core-os.net/amd64-usr/${COREOS_VERSION}/coreos_production_qemu_image.img.bz2"

  if ! [[ $(type -t "image::update_coreos_image_${IMAGE_STORE_TYPE}") == "function" ]]; then
    echo "Image store type currently unsupported"
    return 1
  fi

  image::update_coreos_image_${IMAGE_STORE_TYPE} "${channel}" "${COREOS_VERSION}" "${url}"

  kv::set "latest_coreos_${IMAGE_STORE_TYPE}_${channel}" "${COREOS_VERSION}"
   
  return 0
}

function image::latest_coreos_alpha() {
  kv::get "latest_coreos_${IMAGE_STORE_TYPE}_alpha"
}

function image::latest_coreos_alpha_path() {
  local alpha=$(image::latest_coreos_alpha)
  image::coreos_path "alpha" "$alpha"
}

function image::latest_coreos_stable() {
  kv::get "latest_coreos_${IMAGE_STORE_TYPE}_stable"
}

function image::coreos_path() {
  local channel=${1:?channel}
  local version=${2:?version}
  echo "${IMAGE_ROOT}/coreos/coreos_${channel}_${version}.img"
}

function image::latest_coreos_beta() {
  kv::get "latest_coreos_${IMAGE_STORE_TYPE}_beta"
}

function image::latest_coreos_beta_path() {
  local beta=$(kv::get "latest_coreos_${IMAGE_STORE_TYPE}_beta")
  image::coreos_path "beta" "$beta"
}


function image::latest_coreos_stable_path() {
  local stable=$(image::latest_coreos_stable)
  image::coreos_path "stable" "$stable"
}
