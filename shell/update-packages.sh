#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Functions
#

main() {  
  info "Update system packages."
  update_packages
}

main
