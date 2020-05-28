#!/bin/bash

#
# Bash shell settings: exit on failing commands, unbound variables
#
#set -o errexit
#set -o nounset
#set -o pipefail

#
# Variables
#
# Color definitions
readonly reset='\e[0m'
readonly red='\e[0;31m'
readonly yellow='\e[0;33m'
readonly cyan='\e[0;36m'

#
# Functions
#

# Print the Linux distribution
get_linux_distribution() {

  if [ -f '/etc/redhat-release' ]; then

    # RedHat-based distributions
    cut --fields=1 --delimiter=' ' '/etc/redhat-release' \
      | tr "[:upper:]" "[:lower:]"

  elif [ -f '/etc/lsb-release' ]; then

    # Debian-based distributions
    grep DISTRIB_ID '/etc/lsb-release' \
      | cut --delimiter='=' --fields=2 \
      | tr "[:upper:]" "[:lower:]"

  fi
}

bulk_install() {
    ensure_installed $@
}

install() {
  for i in $@; do
    ensure_installed $i;
  done
}

ensure_installed() {
  if ! is_installed $@; then
    distro=$(get_linux_distribution)
    "install_${distro}" $@ || die "Distribution ${distro} is not supported"
  fi

  info "$@ instaled"
}

is_installed() {
  which $@ > /dev/null 2>&1
}

# Install on a Fedora system.
install_fedora() {
  info "Fedora: installing $@"
  dnf -y install $@
}

# Install on a CentOS system from EPEL
install_centos() {
  version=$(cut --fields=4 --delimiter=' ' '/etc/redhat-release' | cut -c1)
  info "CentOS ${version}: install packages $@"
  if [ "${version}" == "8" ]
  then
    info "Using dnf pakage manager"
    dnf -y install $@
  else
    info "Using yum pakage manager"
    yum -y install $@
  fi
}

# Install on a recent Ubuntu distribution, from the PPA
install_ubuntu() {
  info "Ubuntu: installing $@"
  apt-get -y install $@
}

update_packages() {
  distro=$(get_linux_distribution)
  "update_${distro}" || die "Distribution ${distro} is not supported"

  info "${distro} updated"
}

update_fedora() {
  info "Fedora: Update packages"
  dnf -y update
}

update_centos() {
  version=$(cut --fields=4 --delimiter=' ' '/etc/redhat-release' | cut -c1)
  info "CentOS ${version}: Update packages"
  if [ "${version}" == "8" ]
  then
    info "Using dnf pakage manager"
    dnf -y update
  else
    info "Using yum pakage manager"
    yum -y update
  fi
}

update_ubuntu() {
  info "Ubuntu: Update packages"
  apt-get -y update
}

add_firewall_rules() {
  info "Add firewall rules $@"
  for i in $@; do
    info "rule: $i"
    firewall-cmd --permanent --add-port=$i;
  done

  info "Reload Firewall"
  firewall-cmd --reload
}

add_iptables_rule() {
  info "Add iptables rule $@"
  iptables -I INPUT 1 -p $1 --dport $2 -s $3 -j ACCEPT;

  info "Save iptables rule"
  iptables-save > /etc/sysconfig/iptables
}


# Usage: info [ARG]...
#
# Prints all arguments on the standard output stream
info() {
  printf "${yellow}>>> %s${reset}\n" "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard output stream
debug() {
  printf "${cyan}### %s${reset}\n" "${*}"
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "${red}!!! %s${reset}\n" "${*}" 1>&2
}

# Usage: die MESSAGE
# Prints the specified error message and exits with an error status
die() {
  error "${*}"
  exit 1
}
