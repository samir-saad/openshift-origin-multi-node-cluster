#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Variables
#
disk=""
label="msdos"

type="primary"
start="0"
end="100%"
fs="ext4"


TEMP=`getopt -o ab:c:: --long disk:,label:,type:,start:,end:,fs: -- "$@"`
eval set -- "$TEMP"

while true ; do
  case "$1" in
    --disk ) disk=$2;shift 2;;
    --label ) label=$2;shift 2;;

    --type ) type=$2;shift 2;;
    --start ) start=$2;shift 2;;
    --end ) end=$2;shift 2;;
    --fs ) fs=$2;shift 2;;
    --)shift;break;;
  esac
done

#
# Functions
#

create_disk_label() {
  info "Check disk label"
  parted $disk print
  current_label=$(parted $disk print | grep "Partition Table" | cut --fields=3 --delimiter=' ')
  info "Partition Table: ${current_label}"
  if [ "${current_label}" == "unknown" ]
  then
    info "Create disk label: $label"
    parted $disk mklabel $label
    parted $disk print
  fi
}

create_partition() {
  info "Create partition"
  parted $disk print
  parted -a cylinder $disk mkpart $type $start $end

  partition=$(fdisk -l | grep $disk | tail -1 | cut --fields=1 --delimiter=' ')
  info "Partition $partition created"
  fdisk -l | grep $disk

  info "Make filesystem: $fs"
  if [ "${fs}" == "ext4" ]
  then
    mkfs.ext4 $partition
  elif [ "${fs}" == "xfs" ]
  then
    mkfs.xfs $partition
  else
    warn "File system $fs isn't supported"
  fi

  parted $disk print
}

main() {
  create_disk_label
  create_partition
}

main
