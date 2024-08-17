#!/usr/bin/env bash

# region : set variables

TEMPLATE_VMID=9050
CLOUDINIT_IMAGE_TARGET_VOLUME=local-lvm
TEMPLATE_BOOT_IMAGE_TARGET_VOLUME=local-lvm
BOOT_IMAGE_TARGET_VOLUME=local-lvm
SNIPPET_TARGET_VOLUME=local
SNIPPET_TARGET_PATH=/var/lib/vz/snippets
REPOSITORY_RAW_SOURCE_URL="https://raw.githubusercontent.com/CommetDevTeam/commet_infra/main"
TARGET_BRANCH="main"
VM_LIST=(
    # ---
    # vmid:       proxmox上でVMを識別するID
    # vmname:     proxmox上でVMを識別する名称およびホスト名
    # cpu:        VMに割り当てるコア数(vCPU)
    # mem:        VMに割り当てるメモリ(MB)
    # vmsrvip:    VMのService Segment側NICに割り振る固定IP
    # vmsanip:    VMのStorage Segment側NICに割り振る固定IP
    # targetip:   VMの配置先となるProxmoxホストのIP
    # targethost: VMの配置先となるProxmoxホストのホスト名
    # ---
    #vmid #vmname      #cpu #mem  #vmsrvip    #vmsanip     #targetip    #targethost
    "1001 cp-1 2 8192 192.168.0.11 192.168.0.11 192.168.0.85 pve"
#    "1002 cp-2 2 8192 192.168.0.12 192.168.0.12 192.168.0.85 pve"
#    "1003 cp-3 2 8192 192.168.0.13 192.168.0.13 192.168.0.85 pve"
    "1101 wk-1 4 8192 192.168.0.21 192.168.0.21 192.168.0.85 pve"
    "1102 wk-2 4 8192 192.168.0.22 192.168.0.22 192.168.0.85 pve"
    "1103 wk-3 4 8192 192.168.0.23 192.168.0.23 192.168.0.85 pve"
    "1104 wk-4 4 8192 192.168.0.24 192.168.0.24 192.168.0.85 pve"
)

# endregion

# ---

# region : create template-vm

# delete existing vm

qm stop 1001
qm destroy 1001
qm stop 1102
qm destroy 1102
qm stop 1103
qm destroy 1103
qm stop 1104
qm destroy 1104
qm stop 1101
qm destroy 1101

qm destroy 9050

# download the image(ubuntu 22.04 LTS)
if [ ! -f jammy-server-cloudimg-amd64.img ]; then
    # download the image(ubuntu 22.04 LTS)
    wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
fi
# create a new VM and attach Network Adaptor
# vmbr0=Service Network Segment (172.16.0.0/22)
qm create $TEMPLATE_VMID --cores 2 --memory 4096 --net0 virtio,bridge=vmbr0 --name cp-template

# import the downloaded disk to $TEMPLATE_BOOT_IMAGE_TARGET_VOLUME storage
qm importdisk $TEMPLATE_VMID jammy-server-cloudimg-amd64.img $TEMPLATE_BOOT_IMAGE_TARGET_VOLUME

# finally attach the new disk to the VM as scsi drive
qm set $TEMPLATE_VMID --scsihw virtio-scsi-pci --scsi0 $TEMPLATE_BOOT_IMAGE_TARGET_VOLUME:vm-$TEMPLATE_VMID-disk-0

# add Cloud-Init CD-ROM drive
qm set $TEMPLATE_VMID --ide2 $CLOUDINIT_IMAGE_TARGET_VOLUME:cloudinit

# set the bootdisk parameter to scsi0
qm set $TEMPLATE_VMID --boot c --bootdisk scsi0

# set serial console
#qm set $TEMPLATE_VMID --serial0 socket --vga serial0

# migrate to template
qm template $TEMPLATE_VMID

mkdir -p /var/lib/vz/snippets/

# cleanup

# endregion

# ---

# region : setup vm from template-vm

for array in "${VM_LIST[@]}"
do
    echo "${array}" | while read -r vmid vmname cpu mem vmsrvip vmsanip targetip targethost
    do
        # clone from template
        # in clone phase, can't create vm-disk to local volume
        qm clone "${TEMPLATE_VMID}" "${vmid}" --name "${vmname}" --full true --target "${targethost}"

        # set compute resources
        ssh -n "${targetip}" qm set "${vmid}" --cores "${cpu}" --memory "${mem}" --cpu host

        # move vm-disk to local
        ssh -n "${targetip}" qm move-disk "${vmid}" scsi0 "${BOOT_IMAGE_TARGET_VOLUME}" --delete true

        # resize disk (Resize after cloning, because it takes time to clone a large disk)
        ssh -n "${targetip}" qm resize "${vmid}" scsi0 30G

        # create snippet for cloud-init(user-config)
        # START irregular indent because heredoc
# ----- #
cat << EOF > "$SNIPPET_TARGET_PATH"/"$vmname"-user.yaml
#cloud-config
hostname: ${vmname}
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
runcmd:
  # set ssh_authorized_keys
  - su - cloudinit -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
  - su - cloudinit -c "curl -sS https://github.com/KanameImaichi.keys >> ~/.ssh/authorized_keys"
  - su - cloudinit -c "chmod 600 ~/.ssh/authorized_keys"
  # run install scripts
  - su - cloudinit -c "curl -s ${REPOSITORY_RAW_SOURCE_URL}/onp-k8s/cluster-boot-up/scripts/nodes/k8s-node-setup.sh > ~/k8s-node-setup.sh"
  - su - cloudinit -c "sudo bash ./k8s-node-setup.sh ${vmname} ${TARGET_BRANCH}"
  # change default shell to bash
  - chsh -s $(which bash) cloudinit
EOF
# ----- #
        # END irregular indent because heredoc

        # create snippet for cloud-init(network-config)
        # START irregular indent because heredoc
# ----- #
cat << EOF >  "$SNIPPET_TARGET_PATH"/"$vmname"-network.yaml
version: 1
config:
  - type: physical
    name: ens18
    subnets:
    - type: static
      address: '${vmsrvip}'
      gateway: '192.168.0.1'
  - type: nameserver
    address:
    - '192.168.0.1'
    search:
    - 'pve'
EOF
# ----- #
        # END irregular indent because heredoc
        echo "${vmname}"
        # set snippet to vm
        ssh -n "${targetip}" qm set "${vmid}" --cicustom "user=${SNIPPET_TARGET_VOLUME}:snippets/${vmname}-user.yaml,network=${SNIPPET_TARGET_VOLUME}:snippets/${vmname}-network.yaml"

    done
done

for array in "${VM_LIST[@]}"
do
    echo "${array}" | while read -r vmid vmname cpu mem vmsrvip vmsanip targetip targethost
    do
        # start vm
        ssh -n "${targetip}" qm start "${vmid}"

    done
done

# endregion