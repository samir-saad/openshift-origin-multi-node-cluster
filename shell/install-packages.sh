#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Variables
#
packages=""

TEMP=`getopt -o ab:c:: --long packages: -- "$@"`
eval set -- "$TEMP"

while true ; do
  case "$1" in
    --packages ) packages=$2;shift 2;;
    --)shift;break;;
  esac
done

#
# Functions
#

main() {
  info "Install packages: $packages"
  bulk_install $packages
}

main
