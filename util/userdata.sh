# Userdata setup

function userdata::create() {
  name=${1:?userdata name}
  dir="/var/lib/libvirt/userdata/coreos/${name}"
  mkdir -p "$dir/openstack/latest/"

  cat > "${dir}/openstack/latest/user_data" <<EOF
#cloud-config

ssh_authorized_keys:
 - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyeivCOXMLvMzKvZjPzNSqD8kvkbsI/Ecdxe7V7HZDG8AfliS68frOZI5pl0uqfBet80e5qH/njDvdfKpKuBiAgUZcBz1+LGdrCr+Tn8Bi0ypu+xSpjJjPT0fVgD9qk0lv5TnUmqZD/BZShQjlp6T0MfETSbGppTxRRZIS2CgjO230fktZST8GUJBX/G0HVupqVdbORVdBkbEx4XfJLrmI3HSuA2drlImhCegrByg8r6k2Q/256myWri8Q2X0bVIg93FqcuLGvngGL8kJinwo/zRPo5ucfH0DWsQWtHo6ayx2FycMsCmd56ZU+FH9PBy73ki4ACqsaGh+T8silAR5R cardno:000603824560
 - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMdxqFTG7bPey17ZWg6LbonqASSNJnlmdMg3yiYPuNu6/b4Ffe4iycGAwVl/ODKnEzLZ2aWUhiVrLMv4Z6vml3/l/qU3PPeQRe+TY0afXLbT05xDG2HS/y5SE/6qoynKb2FzJ8YCpI3xdoJ3E4L5+a5vZ1yjknaFcHcL0/g5GCsKo0QpO6dH9Tz+W36Ua/kGXmqMzDaOraXLvTc2TBJ4Mm/CRy6zL773V4GE5e+w4MxdYGpaGZ2EaKw37xFAyx2lH2/RbRt+qTsvGOjfhXuMyOEtsrDEkM7mbRdjuC8WzlutTrDESRJuVAu47HEZjMKCaQ05wgI/LYS3CeolorGDf9tahnjS5s0x7X+NIRkEA0qgpxUwr5T9Z7JKWIIOV90Rbu6CFEfhldNtfA5uD8RLufIiiQTsTZmHjHaPWi98iphb+wMpy8yB4lPPzoWfSuofPVcWaLFoFzGwKkP38XLyeKXEyUgGJPTLPLkGNjQgTBqZlOTL06UR8GNKPtWo5dMCvsFuz0+u34LaeyNg+2i7gvhWZakDZ1EAqWdtj6A+8oAlIEa04OR09xlfdjA9BMA4xGyq9sOKn99tV5qTIZl3X+MIxxPUm0TYXulM4kByeKROAvQhgwSUJAE63qVddBnl+PAsUZPREl8l/ccuytZIlnDn2RY0LlIXGYb0tIEykSqw== cardno:000604162160

hostname: "${name}.wobscale.euank.com"

coreos:
  update:
    reboot-strategy: off
  units:
  - name: sshd.socket
    command: restart
    runtime: true
    content: |
      [Socket]
      ListenStream=222
      FreeBind=true
      Accept=yes
EOF
  echo "${dir}"
}


function userdata::create_k8s() {
  name=${1:?userdata name}
  ip=${2:?userdata ip}
  dir="/var/lib/libvirt/userdata/coreos/${name}"
  mkdir -p "$dir/openstack/latest/"
  hostname="${name}.k8s.euank.com"
  source "${ROOT}/secret/aws-k8s-r53"

  cat > "${dir}/openstack/latest/user_data" <<EOF
#cloud-config

ssh_authorized_keys:
 - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyeivCOXMLvMzKvZjPzNSqD8kvkbsI/Ecdxe7V7HZDG8AfliS68frOZI5pl0uqfBet80e5qH/njDvdfKpKuBiAgUZcBz1+LGdrCr+Tn8Bi0ypu+xSpjJjPT0fVgD9qk0lv5TnUmqZD/BZShQjlp6T0MfETSbGppTxRRZIS2CgjO230fktZST8GUJBX/G0HVupqVdbORVdBkbEx4XfJLrmI3HSuA2drlImhCegrByg8r6k2Q/256myWri8Q2X0bVIg93FqcuLGvngGL8kJinwo/zRPo5ucfH0DWsQWtHo6ayx2FycMsCmd56ZU+FH9PBy73ki4ACqsaGh+T8silAR5R cardno:000603824560
 - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMdxqFTG7bPey17ZWg6LbonqASSNJnlmdMg3yiYPuNu6/b4Ffe4iycGAwVl/ODKnEzLZ2aWUhiVrLMv4Z6vml3/l/qU3PPeQRe+TY0afXLbT05xDG2HS/y5SE/6qoynKb2FzJ8YCpI3xdoJ3E4L5+a5vZ1yjknaFcHcL0/g5GCsKo0QpO6dH9Tz+W36Ua/kGXmqMzDaOraXLvTc2TBJ4Mm/CRy6zL773V4GE5e+w4MxdYGpaGZ2EaKw37xFAyx2lH2/RbRt+qTsvGOjfhXuMyOEtsrDEkM7mbRdjuC8WzlutTrDESRJuVAu47HEZjMKCaQ05wgI/LYS3CeolorGDf9tahnjS5s0x7X+NIRkEA0qgpxUwr5T9Z7JKWIIOV90Rbu6CFEfhldNtfA5uD8RLufIiiQTsTZmHjHaPWi98iphb+wMpy8yB4lPPzoWfSuofPVcWaLFoFzGwKkP38XLyeKXEyUgGJPTLPLkGNjQgTBqZlOTL06UR8GNKPtWo5dMCvsFuz0+u34LaeyNg+2i7gvhWZakDZ1EAqWdtj6A+8oAlIEa04OR09xlfdjA9BMA4xGyq9sOKn99tV5qTIZl3X+MIxxPUm0TYXulM4kByeKROAvQhgwSUJAE63qVddBnl+PAsUZPREl8l/ccuytZIlnDn2RY0LlIXGYb0tIEykSqw== cardno:000604162160

hostname: "${hostname}"

coreos:
  update:
    reboot-strategy: off
  units:
  - name: sshd.socket
    command: restart
    runtime: true
    content: |
      [Socket]
      ListenStream=222
      FreeBind=true
      Accept=yes
  - name: r53-register.service
    command: start
    enable: true
    content: |
      [Unit]
      Description=r53
      After=docker.service network.online
      Requires=docker.service 

      [Service]
      TimeoutStartSec=0
      ExecStartPre=-/usr/bin/docker rm -f r53-registerer
      ExecStartPre=/usr/bin/docker pull euank/route53-registerer:latest
      ExecStart=/usr/bin/docker run --name=r53-registerer -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY}" \
      		-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_KEY}" \
      		-e REGISTER_IP=$ip \
      		-e REGISTER_DOMAIN="${hostname}" \
      		euank/route53-registerer:latest
      ExecStop=/usr/bin/docker stop r53-registerer

      [Install]
      WantedBy=multi-user.target


EOF
  echo "${dir}"

}
