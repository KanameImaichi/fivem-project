#!/usr/bin/env bash

# region : set variables

TEMPLATE_VMID=9050
CLOUDINIT_IMAGE_TARGET_VOLUME=local-lvm
TEMPLATE_BOOT_IMAGE_TARGET_VOLUME=local-lvm
BOOT_IMAGE_TARGET_VOLUME=local-lvm
SNIPPET_TARGET_VOLUME=local
SNIPPET_TARGET_PATH=/var/lib/vz/snippets
REPOSITORY_RAW_SOURCE_URL="https://raw.githubusercontent.com/KanameImaichi/fivem-project/main"
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
    "100 cp-1 2 8192 192.168.0.31 192.168.0.31 192.168.0.85 pve"
#    "1002 cp-2 2 8192 192.168.0.12 192.168.0.12 192.168.0.85 pve"
#    "1003 cp-3 2 8192 192.168.0.13 192.168.0.13 192.168.0.85 pve"
#    "1101 wk-1 4 8192 192.168.0.21 192.168.0.21 192.168.0.85 pve"
#    "1102 wk-2 4 8192 192.168.0.22 192.168.0.22 192.168.0.85 pve"
#    "1103 wk-3 4 8192 192.168.0.23 192.168.0.23 192.168.0.85 pve"
)

# endregion

# ---

# region : create template-vm

# delete existing vm


# download the image(ubuntu 22.04 LTS)
if [ ! -f jammy-server-cloudimg-amd64.img ]; then
    # download the image(ubuntu 22.04 LTS)
    wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
fi
# create a new VM and attach Network Adaptor
# vmbr0=Service Network Segment (172.16.0.0/22)
qm create 100 --cores 2 --memory 4096 --net0 virtio,bridge=vmbr0 --name cp-template

# import the downloaded disk to $TEMPLATE_BOOT_IMAGE_TARGET_VOLUME storage
qm importdisk 100 jammy-server-cloudimg-amd64.img $TEMPLATE_BOOT_IMAGE_TARGET_VOLUME

# finally attach the new disk to the VM as scsi drive
qm set 100 --scsihw virtio-scsi-pci --scsi0 $TEMPLATE_BOOT_IMAGE_TARGET_VOLUME:vm-100-disk-0

# add Cloud-Init CD-ROM drive
qm set 100 --ide2 $CLOUDINIT_IMAGE_TARGET_VOLUME:cloudinit

# set the bootdisk parameter to scsi0
qm set 100 --boot c --bootdisk scsi0

# set serial console
#qm set $TEMPLATE_VMID --serial0 socket --vga serial0

# migrate to template
#qm template $TEMPLATE_VMID
#
#mkdir -p /var/lib/vz/snippets/

# cleanup

# endregion

# ---

# region : setup vm from template-vm


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
    - '8.8.8.8'
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