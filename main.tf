provider "proxmox" {
 pm_api_url   = "https://192.168.1.171:8006/api2/json"
 pm_user      = "root@pam"
 pm_password  = "florida1"
 pm_tls_insecure = true
}
 

resource "proxmox_vm_qemu" "win2k19-vm" {
  ## Wait for the cloud-config file to exist

  name        = "Danube"
  target_node = "pve2"

  # Clone from cloudinit template
  clone      = "danube-w2k19"
  full_clone = true
  #os_type = "cloud-init"


    agent = 1
    cores      = 1
    sockets = 1
    memory = 4096

    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"
    boot = "order=scsi0"

#  disk {
#    size    = "80G"
#    type    = "sata"
#    storage = "DefaultPool"
#  }


    disks {
        scsi {
            # this will just map to the boot disk in vm template
            scsi0{
                disk{
                # slot     = 0
                    size     = "32" # size must match the disk in template
                # type     = "scsi"
                    storage  = "local-lvm"
                    # Enables thin-provisioning
                    #discard = "on"
                    #iothread = 1
                }
            }
        }
    }


  # Set the network
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
}


resource "proxmox_vm_qemu" "virtual_machine" {
 name       = "Orinoco"
 agent = 1
 target_node = "pve"
 clone      = "ubuntu-24.04-srv-amd64"
 full_clone = "true"
 #storage    = "local-lvm"
 cores      = 1
 sockets = 1
 memory     = 2048
 scsihw = "virtio-scsi-pci"
 bootdisk = "scsi0"
 boot = "order=scsi0"


disks {
    scsi {
        # this will just map to the boot disk in vm template
        scsi0{
            disk{
            # slot     = 0
                size     = "32" # size must match the disk in template
            # type     = "scsi"
                storage  = "local-lvm"
                # Enables thin-provisioning
                #discard = "on"
                #iothread = 1
            }
        }
        # extra disk for test purposes 
        scsi1{
            disk{
            # slot     = 0
                size     = "5"
            # type     = "scsi"
                storage  = "local-lvm"
                # Enables thin-provisioning
                #discard = "on"
                #iothread = 1
            }
        }
    }
}

  network {
    model     = "virtio"
    bridge    = "vmbr0"
    #tag       = 101
    firewall  = false
    link_down = false
  }

}

