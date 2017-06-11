
function util::certs::_getfile() {
  [[ -f "${SECRET_CERT_DIR}/${1}" ]] || {
    1>&2 echo "no '${1}' found in ${SECRET_CERT_DIR}"
    exit 1
  }
  cat "${SECRET_CERT_DIR}/${1}"
}

function util::certs::get_ca() {
  util::certs::_getfile "ca.pem"
}

function util::certs::get_ca_root() {
  util::certs::_getfile "ca-root.pem"
}

function util::certs::get_ca_key() {
  util::certs::_getfile "ca-key.pem"
}

function util::certs::get_apiserver_pem() {
  util::certs::_getfile "apiserver.pem"
}

function util::certs::get_apiserver_key() {
  util::certs::_getfile "apiserver-key.pem"
}
