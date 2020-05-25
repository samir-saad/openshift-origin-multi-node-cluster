#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh


#
# Functions
#
fix_network() {
  info "delete eth0"
  rm -f /etc/sysconfig/network-scripts/ifcfg-eth0
  info "Set bridged as eth0"
  mv /etc/sysconfig/network-scripts/ifcfg-eth1 /etc/sysconfig/network-scripts/ifcfg-eth0
  sed -i "s/DEVICE=eth1/DEVICE=eth0/g" /etc/sysconfig/network-scripts/ifcfg-eth0
  cat /etc/sysconfig/network-scripts/ifcfg-eth0
}

main() {
  fix_network
  
}

main
