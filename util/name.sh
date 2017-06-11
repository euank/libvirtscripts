
function name::random_name() {
  sort -R "${ROOT}/util/misc_data/namelist.txt" | head -n 1
}

# https://gist.github.com/0x783czar/4115108
function name::random_mac() {
  hexchars="0123456789abcdef"
  echo "24:df:86$(
    for i in {1..6}; do
      echo -n ${hexchars:$(( $RANDOM % 16 )):1}
    done | sed -e 's/\(..\)/:\1/g'
  )"
}
