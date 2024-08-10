terraform {
  required_providers {
    proxmox = {
    #  source  = "telmate/proxmox"
    #  version = "2.9.14"
      source  = "thegameprofi/proxmox"
      version = ">= 2.9.15"
    }
  }
  backend "local" {
  }
}
 