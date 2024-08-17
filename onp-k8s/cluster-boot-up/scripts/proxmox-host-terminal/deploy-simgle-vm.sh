#!/usr/bin/env bash

# region : set variables
VMID=100
TEMPLATEID=9000
VMNAME="ubuntu-cloud-vm"
MEMORY=2048
CORES=2
DISK_SIZE=20G
BRIDGE=vmbr0
SNIPPET_TARGET_VOLUME=local
SNIPPET_TARGET_PATH=/var/lib/vz/snippets
TARGET_IP=192.168.0.85
# endregion

# Download the image (Ubuntu 22.04 LTS)
qm shutdown $VMID
qm destroy $VMID
qm destroy 9000

if [ ! -f jammy-server-cloudimg-amd64.img ]; then
    wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
fi

# Create a new VM template
qm create $TEMPLATEID --name "ubuntu-cloud-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk $TEMPLATEID jammy-server-cloudimg-amd64.img local-lvm
qm set $TEMPLATEID --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$TEMPLATEID-disk-0
qm set $TEMPLATEID --boot c --bootdisk scsi0
qm set $TEMPLATEID --ide2 local-lvm:cloudinit
qm template $TEMPLATEID

# Ensure snippets directory exists
mkdir -p $SNIPPET_TARGET_PATH

# Cleanup previous VM if it exists


# Setup VM from template
qm clone $TEMPLATEID $VMID --name $VMNAME

# Configure the cloned VM
qm set $VMID --memory $MEMORY --cores $CORES --net0 virtio,bridge=$BRIDGE
qm resize $VMID scsi0 $DISK_SIZE

# Create user-data snippet
cat << EOF > "$SNIPPET_TARGET_PATH/$VMNAME-user.yaml"
#cloud-config
hostname: $VMNAME
timezone: Asia/Tokyo
manage_etc_hosts: true
chpasswd:
  expire: False
users:
  - default
  - name: cloudinit
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    # mkpasswd --method=SHA-512 --rounds=4096
    # password is zaq12wsx
    passwd: \$6\$rounds=4096\$Xlyxul70asLm\$9tKm.0po4ZE7vgqc.grptZzUU9906z/.vjwcqz/WYVtTwc5i2DWfjVpXb8HBtoVfvSY61rvrs/iwHxREKl3f20
ssh_pwauth: true
ssh_authorized_keys: []
package_upgrade: true
EOF

# Create network-config snippet
cat << EOF > "$SNIPPET_TARGET_PATH/$VMNAME-network.yaml"
version: 1
config:
  - type: physical
    name: ens18
    subnets:
    - type: static
      address: '192.168.0.100' # Change this to the actual IP you want to assign
      gateway: '192.168.0.1'
  - type: nameserver
    address:
    - '8.8.8.8'
    search:
    - 'pve'
EOF

# Set snippets for cloud-init
qm set $VMID --cicustom "user=$SNIPPET_TARGET_VOLUME:snippets/$VMNAME-user.yaml,network=$SNIPPET_TARGET_VOLUME:snippets/$VMNAME-network.yaml"

# Start the VM
qm start $VMID

echo "VM $VMID ($VMNAME) has been created and started."

docker run -d \
  --name FiveM \
  --restart=on-failure \
  -e LICENSE_KEY=cfxk_1G4cONU3fhLNI5lHJA1KE_3OafcW \
  -p 30120:30120 \
  -p 30120:30120/udp \
  -v /volumes/fivem:/config \
  -ti \
  spritsail/fivem

docker run -d \
  --name FiveM \
  --restart=on-failure \
  -e NO_DEFAULT_CONFIG=1 \
  -p 30120:30120 \
  -p 30120:30120/udp \
  -p 40120:40120 \
  -v /volumes/fivem:/config \
  -v /volumes/txData:/txData \
  -ti \
  spritsail/fivem