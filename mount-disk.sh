#!/bin/bash

# Initializing arrays
declare -A DISKS_LIST
DISKS_LIST["DOCKER_DISK"]="/dev/sdc;/applis"
DISKS_LIST["MOUNT_POINT"]="/dev/sdd;/var/lib/docker"
FS_TYPE="ext4"

# Reading arrays by converting them into lists
read_arrays() {
  for key in "${!DISKS_LIST[@]}"; do
    local elements=${DISKS_LIST[$key]}
    while IFS=';' read -r disk mountpoint
    do
        echo "disk=$disk mountpoint=$mountpoint"
        check_disk
        check_mountpoint
	create_partition
    done <<< "$elements"

  done
}

check_disk() {
    if [ ! -b "$disk" ]; then
        echo "Error : Disk does not exist."
        exit 1
    fi
}

check_mountpoint() {
    if [ ! -b "$mountpoint" ]; then
	echo "Mountpoint doesn't exist, creating the directory $mountpoint."
	echo "sudo mkdir -p $mountpoint"
        sudo mkdir -p $mountpoint
    fi
}

create_partition() {
    # Creating partition label
    echo "parted -s $disk mklabel gpt"
    sudo parted -s $disk mklabel gpt

    # Creating partition
    echo "sudo parted -s -a optimal $disk mkpart primary 0% 100%"
    sudo parted -s -a optimal "$disk" mkpart primary 0% 100%

    PARTITION="${disk}1"

    # Creating filesystem from partition
    echo "sudo mkfs -t $FS_TYPE $PARTITION"
    sudo mkfs -t $FS_TYPE $PARTITION

    # Mounting partition on mountpoint
    echo "sudo mount $PARTITION $mountpoint"
    sudo mount $PARTITION $mountpoint

    # Retrieving UUID to put it in /etc/fstab
    UUID=$(sudo blkid -s UUID -o value "$PARTITION")
    echo "UUID=$UUID $disk $FS_TYPE defaults 0 2" | sudo tee -a /etc/fstab
    echo "Disk $disk mounted on $mountpoint."
}

read_arrays
