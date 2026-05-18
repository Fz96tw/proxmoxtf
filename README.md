# proxmoxtf

Terraform configuration for provisioning VMs on a home-lab Proxmox VE cluster using the [`thegameprofi/proxmox`](https://registry.terraform.io/providers/thegameprofi/proxmox) provider.

## What it does

Provisions three QEMU VMs across two Proxmox nodes by cloning pre-built templates:

| VM Name  | OS                  | Node | Template               | Clone Type  | RAM   | Disks                        |
|----------|---------------------|------|------------------------|-------------|-------|------------------------------|
| congo    | Windows Server 2019 | pve2 | win2k19-cloudinit      | linked      | 2 GB  | virtio0: 32 GB, virtio1: 1 GB |
| indus    | Windows Server 2019 | pve2 | win2k19-cloudinit      | linked      | 2 GB  | virtio0: 32 GB, virtio1: 1 GB |
| Orinoco  | Ubuntu 24.04 Server | pve  | ubuntu-24.04-srv-amd64 | full        | 2 GB  | scsi0: 32 GB, scsi1: 5 GB    |

## Cluster layout

```
Home Network (192.168.1.0/24)
        |
        | vmbr0 (bridge)
        |
  +-----+-----+
  |           |
 pve         pve2
(Ubuntu)   (Windows x2)
  |           |
  Orinoco   congo
            indus

Proxmox API: https://192.168.1.171:8006
```

## VM details

### Windows VMs (congo, indus)

- OS type: `win10` (Proxmox's designation for Win2019)
- NIC: `e1000` model on `vmbr0`, DHCP
- Controller: `virtio-scsi-pci`
- Boot disk: `virtio0`
- QEMU guest agent enabled
- **congo** stores disks on `local-lvm`; **indus** uses `vg_local-lvm2`

### Ubuntu VM (Orinoco)

- OS type: `l26` (Linux kernel 2.6+)
- NIC: `virtio` model on `vmbr0`
- Controller: `virtio-scsi-pci`
- Boot disk: `scsi0`; extra `scsi1` (5 GB) for testing
- QEMU guest agent enabled

## Provider

Uses `thegameprofi/proxmox` >= 2.9.15 (currently locked to 2.10.0).  
This is a fork of the original `telmate/proxmox` provider with additional bug fixes — the lock file pins the exact release hash.

```
# backend.tf
source  = "thegameprofi/proxmox"
version = ">= 2.9.15"
```

State is stored locally (no remote backend).

## Usage

```bash
terraform init
terraform plan
terraform apply
```

To destroy a specific VM without touching the others:

```bash
terraform destroy -target proxmox_vm_qemu.virtual_machine   # Orinoco
terraform destroy -target proxmox_vm_qemu.win2k19-vm        # congo
terraform destroy -target proxmox_vm_qemu.win2k19-vm-2      # indus
```

## Prerequisites

- Proxmox VE node(s) reachable at `192.168.1.171`
- VM templates already present on the respective nodes:
  - `win2k19-cloudinit` on `pve2`
  - `ubuntu-24.04-srv-amd64` on `pve`
- QEMU guest agent installed inside each template image

## Known issues / gotchas

- **Linked vs full clone**: Windows VMs use linked clones (`full_clone = false`) so the base template must remain on the node. Orinoco uses a full clone and is independent of its template after provisioning.
- **Disk size must match template**: The `size` value in the `disks` block must match the disk size in the source template or Terraform will error on plan.
- **TLS verification disabled**: `pm_tls_insecure = true` is set because the Proxmox API uses a self-signed certificate. Do not use this in production.
- **Hardcoded credentials**: `pm_password` is currently in plain text in `main.tf`. Move it to a `terraform.tfvars` file (gitignored) or use an environment variable (`PM_PASS`) before sharing or committing this repo.
