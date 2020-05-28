#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Variables
#
timezone=""

TEMP=`getopt -o ab:c:: --long timezone: -- "$@"`
eval set -- "$TEMP"

while true ; do
  case "$1" in
    --timezone ) timezone=$2;shift 2;;
    --)shift;break;;
  esac
done

#
# Functions
#
set_timezone() {
  info "Set timezone $timezone"
  yes | cp -f /usr/share/zoneinfo/$timezone /etc/localtime
}

main() {
  info "date before setting timezone: $(date)"
  set_timezone
  info "date after setting timezone: $(date)"
}

main
