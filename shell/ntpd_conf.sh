#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Functions
#
configure_ntpd() {
  info "Install ntpd"
  install ntp
  
  info "Configure ntpd"
  chkconfig ntpd on
  ntpdate pool.ntp.org
  systemctl disable chronyd
  systemctl enable ntpd 
  systemctl start ntpd 
  date
}

main() {
  configure_ntpd
}

main
