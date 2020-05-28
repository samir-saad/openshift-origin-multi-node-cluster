#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Variables
#
disk=""
dest=""

TEMP=`getopt -o ab:c:: --long disk:,dest: -- "$@"`
eval set -- "$TEMP"

while true ; do
  case "$1" in
    --disk ) disk=$2;shift 2;;
    --dest ) dest=$2;shift 2;;
    --)shift;break;;
  esac
done

#
# Functions
#

create_or_sync_dest() {
  info "Check if directory $dest exists"

  if [ -d "$dest" ]
  then
      info "Directory $dest exists."
      tmp_dir=/mnt/tmp_dir
      info "Create temp dir $tmp_dir"
      umount $tmp_dir
      rm -rf $tmp_dir && mkdir -p $tmp_dir

      info "Mount $disk to $tmp_dir"
      mount $disk $tmp_dir

      info "rsync $dest to $tmp_dir"
      rsync -zah $dest/* $tmp_dir

      info "Unmount temp dir $tmp_dir"
      umount $tmp_dir  $dest

      info "Delete local destination $dest"
      rm -rf $dest/*

  else
      info "Directory $dest does not exists."
      info "Create directory $dest"
      mkdir -p $dest
  fi
}

mount_disk() {
  info "Mount $disk to $dest"
  mount $disk $dest

  info "Show mounts"
  df -hl

  info "Get disk filesystem type"
  df -Th | grep $disk
  fstype=$(df -Th | grep $disk | awk '{print $2}')
  info "FS type: $fstype"

  info "Add mount point to fstab"
  echo "$disk    $dest    $fstype    defaults    0 0" >> /etc/fstab

  info "Cat fstab"
  cat /etc/fstab
  mount -a
}

main() {
  create_or_sync_dest
  mount_disk
}

main
