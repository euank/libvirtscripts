
function name::random_name() {
  sort -R "${ROOT}/util/misc_data/namelist.txt" | head -n 1
}
