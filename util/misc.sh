
function util::misc::indent() {
  str=${1:?must provide string to indent}
  count=${2:?must provide count}
  "${ROOT}/bin/sprig" --set s="${str}" <(echo "{{ .s | indent $count }}")
}
