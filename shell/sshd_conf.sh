#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Variables
#
ROOT_HOME="/root"
ROOT_SSH_HOME="$ROOT_HOME/.ssh"
ROOT_AUTHORIZED_KEYS="$ROOT_SSH_HOME/authorized_keys"
VAGRANT_HOME="/home/vagrant"
VAGRANT_SSH_HOME="$VAGRANT_HOME/.ssh"
VAGRANT_AUTHORIZED_KEYS="$VAGRANT_SSH_HOME/authorized_keys"

#
# Functions
#
add_private_key() {
  info "Add private key to $1"
  mkdir -p $1
  cp /vagrant/keys/id_rsa $1/id_rsa
  chmod 600 $1/id_rsa
}

add_authorized_key() {
  info "Add authorized key to $1"
  cat /vagrant/keys/id_rsa.pub >> $1
  chmod 644 $1
}

configure_sshd() {
  info "Configure sshd"
  sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
  sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
  
  echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
  
  info "Restart sshd"
  systemctl restart sshd
}

main() {
  info "Add ssh keys"
  add_private_key $ROOT_SSH_HOME
  add_private_key $VAGRANT_SSH_HOME
  
  add_authorized_key $ROOT_AUTHORIZED_KEYS
  add_authorized_key $VAGRANT_AUTHORIZED_KEYS
  
  chown -R root:root $ROOT_SSH_HOME
  chown -R vagrant:vagrant $VAGRANT_SSH_HOME
  
  configure_sshd
}

main
