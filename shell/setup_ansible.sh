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
  #install ansible
  wget -O /root/ansible-2.6.20-1.el7.ans.noarch.rpm https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.6.20-1.el7.ans.noarch.rpm
  yum localinstall -y /root/ansible-2.6.20-1.el7.ans.noarch.rpm
  
  cp -f /vagrant/ansible/ansible-hosts.yaml /etc/ansible/hosts
  
  ansible --version
  
  ansible all -m ping
}

main