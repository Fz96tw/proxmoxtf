provider "proxmox" {
 pm_api_url   = "https://192.168.1.171:8006/api2/json"
 pm_user      = "root@pam"
 pm_password  = "florida1"
 pm_tls_insecure = true
}
 


resource "proxmox_vm_qemu" "my_vm" {
 name       = "ubuntu-test2"
 agent = 0
 target_node = "pve"
 clone      = "ubuntu-24.04-server-amd64-template"
 full_clone = "true"
 #storage    = "local-lvm"
 cores      = 1
 sockets = 1
 memory     = 2048
 scsihw = "virtio-scsi-pci"
 bootdisk = "scsi0"

disks {
scsi {
    scsi0{
        disk{
           # slot     = 0
            size     = "32"
           # type     = "scsi"
            storage  = "local-lvm"
            # Enables thin-provisioning
            #discard = "on"
            #iothread = 1
        }
    }
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


#   boot = "order=scsi0"
}

