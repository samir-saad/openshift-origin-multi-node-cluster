#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Variables
#
gateway=""
device=""

TEMP=`getopt -o ab:c:: --long gateway:,device: -- "$@"`
eval set -- "$TEMP"

while true ; do
  case "$1" in
    --gateway ) gateway=$2;shift 2;;
    --device ) device=$2;shift 2;;
    --)shift;break;;
  esac
done

#
# Functions
#
print_network_defaults() {
  info "Print gateway details"
  route -n
  ip route | grep default
  ip -4 route get 8.8.8.8
  default_iface=$(awk '$2 == 00000000 { print $1 }' /proc/net/route)
  ip addr show dev "$default_iface" | awk '$1 ~ /^inet/ { sub("/.*", "", $2); print $2 }'
}

set_default_gateway() {
  info "Set default gateway to $gateway"
  echo "GATEWAY=$gateway" >> /etc/sysconfig/network
  info "Set default device to $device"
  echo "GATEWAYDEV=$device" >> /etc/sysconfig/network
  systemctl restart network NetworkManager
}

main() {
  print_network_defaults
  set_default_gateway
  print_network_defaults
}

main
