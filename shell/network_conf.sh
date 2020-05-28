#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Variables
#
dns=""

TEMP=`getopt -o ab:c:: --long dns: -- "$@"`
eval set -- "$TEMP"

while true ; do
  case "$1" in
    --dns ) dns=$2;shift 2;;
    --)shift;break;;
  esac
done

#
# Functions
#

override_hosts_file() {
info "Configure hosts file"
cat << EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain
::1         localhost localhost.localdomain

EOF
}

configure_network_manager() {
  info "Configure NetworkManager"

  # Disable DNS Overriding
  sed -i "/\[main\]/a dns=none" /etc/NetworkManager/NetworkManager.conf

  # Restart NetworkManager
  systemctl restart network NetworkManager
}

add_dns() {
  info "Adding DNS"

  sed -i "/local.net/a nameserver $dns" /etc/resolv.conf

  # Restart network
  systemctl restart NetworkManager
}

main() {
  override_hosts_file
  configure_network_manager
  add_dns
}

main
