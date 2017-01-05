
function kv::set() {
  key=$1
  value=$2

  mkdir -p "${ROOT}"/data
  echo "$value" > "${ROOT}/data/${key}"
}

function kv::get() {
  cat "${ROOT}/data/${1}"
}
