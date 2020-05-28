#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Functions
#
install_dns() {
  info "Installing bind"
  install bind bind-utils
}

configure_dns() {
  info "Configuring bind"
  info "Backup named.conf"
  cp -f /etc/named.conf /etc/named.conf.bkp
  info "Copy new named.conf"
  cp -f /vagrant/dns/named.conf /etc/named.conf
  
  info "Copy forward and reverse configurations"
  cp -f /vagrant/dns/forward.ocp.local /var/named/forward.ocp.local
  cp -f /vagrant/dns/reverse.ocp.local /var/named/reverse.ocp.local
  info "Copy wildcard and subdomain configurations"
  cp -f /vagrant/dns/forward.cloudapps.ocp.local /var/named/forward.cloudapps.ocp.local
  
  info "Configuring Permissions"
  chgrp named -R /var/named
  chown -v root:named /etc/named.conf
  restorecon -rv /var/named
  restorecon /etc/named.conf
  
  info "Enable and start DNS service"
  systemctl enable named
  systemctl start named
}

configure_firewall() {
  info "Enable and start firewall service"
  systemctl enable firewalld
  systemctl start firewalld
  
  info "Firewall configurations for DNS"
  add_firewall_rules 53/tcp 53/udp
}

configure_iptables() {
  info "iptables configurations for DNS"
  add_iptables_rule tcp 53 0.0.0.0/0
  add_iptables_rule udp 53 0.0.0.0/0
}

test_dns() {
  info "Test DNS configuration"
  named-checkconf /etc/named.conf
  
  info "Check Forward zone"
  named-checkzone ocp.local.net /var/named/forward.ocp.local
  
  info "Check Reverse zone"
  named-checkzone ocp.local.net /var/named/reverse.ocp.local
  
  info "Check Wildcard zone"
  named-checkzone cloudapps.ocp.local.net /var/named/forward.cloudapps.ocp.local
  
  info "Test DNS server"
  dig infra.ocp.local.net
  nslookup ocp.local.net
  
  info "Test Wildcard"
  dig XXX.cloudapps.ocp.local.net
  nslookup cloudapps.ocp.local.net
}

main() {
  info "Installing and Configuring DNS."
  install_dns
  configure_dns
  #configure_firewall
  configure_iptables
  test_dns
}

main
