#!/bin/bash

DISK="/dev/sdb"
MOUNT_POINT="/applis"
FS_TYPE="ext4"

if [ ! -b "$DISK" ]; then
    echo "Erreur : Le disque $DISK n'existe pas."
    exit 1
fi

if [ ! -d "$MOUNT_POINT" ]; then
    sudo mkdir -p "$MOUNT_POINT"
fi

sudo parted -s "$DISK" mklabel gpt
sudo parted -s -a optimal "$DISK" mkpart primary 0% 100%

PARTITION="${DISK}1"
sudo mkfs -t "$FS_TYPE" "$PARTITION"

sudo mount "$PARTITION" "$MOUNT_POINT"

UUID=$(sudo blkid -s UUID -o value "$PARTITION")
echo "UUID=$UUID $MOUNT_POINT $FS_TYPE defaults 0 2" | sudo tee -a /etc/fstab

echo "Le disque $DISK est monté sur $MOUNT_POINT."
