function libvirt::domain::add_ignition() {
  file=${1:?must set domain xml file}
  ignition=${2:?must set ignition file path}

  xmlstarlet ed -P -L -i "//domain" -t attr -n "xmlns:qemu" --value "http://libvirt.org/schemas/domain/qemu/1.0" "${file}"
  xmlstarlet ed -P -L -s "//domain" -t elem -n "qemu:commandline" "${file}"
  xmlstarlet ed -P -L -s "//domain/qemu:commandline" -t elem -n "qemu:arg" "${file}"
  xmlstarlet ed -P -L -s "(//domain/qemu:commandline/qemu:arg)[1]" -t attr -n "value" -v "-fw_cfg" "${file}"
  xmlstarlet ed -P -L -s "//domain/qemu:commandline" -t elem -n "qemu:arg" "${file}"
  xmlstarlet ed -P -L -s "(//domain/qemu:commandline/qemu:arg)[2]" -t attr -n "value" -v "name=opt/com.coreos/config,file=${ignition}" "${file}"
}
