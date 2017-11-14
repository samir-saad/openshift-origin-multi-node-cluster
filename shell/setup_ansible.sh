#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Functions
#

main() {
  info "Installing and Configuring Ansible."
  install ansible
  
  cp -f /vagrant/ansible/ansible-hosts.yaml /etc/ansible/hosts
  
  ansible all -m ping
}

main