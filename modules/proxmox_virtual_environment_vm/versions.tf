terraform {
  required_version = ">= 1.9"

  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      # Provider ainda em 0.x: o teto < 1.0 segue a convenção de travar antes da próxima major.
      version = ">= 0.123, < 1.0"
    }
  }
}
