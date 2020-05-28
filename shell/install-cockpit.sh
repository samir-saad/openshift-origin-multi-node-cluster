#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Variables
#
port=""
# cockpit cockpit-networkmanager cockpit-dashboard cockpit-storaged cockpit-packagekit cockpit-docker cockpit-kubernetes cockpit-machines cockpit-selinux cockpit-kdump
packages="cockpit cockpit-networkmanager cockpit-dashboard cockpit-storaged cockpit-packagekit"


TEMP=`getopt -o ab:c:: --long port:,packages: -- "$@"`
eval set -- "$TEMP"

while true ; do
  case "$1" in
    --port ) port=$2;shift 2;;
    --packages ) packages=$2;shift 2;;
    --)shift;break;;
  esac
done

#
# Functions
#

main() {
  info "Install Cockpit packages: $packages"
  bulk_install $packages

#   sed -i "s/enabled=1/enabled=0/g" /etc/yum/pluginconf.d/subscription-manager.conf
#
# cat << EOF > /etc/yum/pluginconf.d/enabled_repos_upload.conf
# [main]
# enabled=0
# supress_debug=False
# supress_errors=False
# EOF

  if [ ! -z "${port// }" ]
  then
      info "Set cockpit port to $port"
      mkdir -p /etc/systemd/system/cockpit.socket.d/

cat << EOF > /etc/systemd/system/cockpit.socket.d/listen.conf
[Socket]
ListenStream=
ListenStream=$port
EOF

      semanage port -a -t websm_port_t -p tcp $port
      systemctl daemon-reload

  fi

  systemctl enable --now cockpit.service cockpit.socket
  systemctl start cockpit.service cockpit.socket

  #firewall-cmd --add-service=cockpit --permanent
  #firewall-cmd --reload
}

main
