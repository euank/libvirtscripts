
function kube::create_worker_cert() {
  name=${1:?Must provide worker fqdn}
  ip=${2:?Must provide worker ip}

  keydir="${ROOT}/secret/k8s-certs"

  if [[ -f "${keydir}/${name}-worker-key.pem" ]]; then
    echo "${keydir}/${name}-worker-key.pem already exists"
    exit 1
  fi

  openssl genrsa -out "${keydir}/${name}-worker-key.pem" 4096
  WORKER_IP=$ip openssl req -new -key "${keydir}/${name}-worker-key.pem" -out "${keydir}/${name}-worker.csr" -subj "/CN=${name}" -config "${keydir}/worker-openssl.cnf"
  WORKER_IP=$ip openssl x509 -req -in "${keydir}/${name}-worker.csr" -CA "${keydir}/ca.pem" -CAkey "${keydir}/ca-key.pem" -CAcreateserial -out "${keydir}/${name}-worker.pem" -days 1000 -extensions v3_req -extfile "${keydir}/worker-openssl.cnf"
}
