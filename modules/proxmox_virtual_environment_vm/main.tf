resource "proxmox_virtual_environment_vm" "this" {
  name      = var.name
  vm_id     = var.vm_id
  node_name = var.node_name
  tags      = var.tags
  on_boot   = true
  started   = true

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  agent {
    enabled = var.agent_enabled
  }

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = var.disk_size_gb
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    datastore_id = var.datastore_id

    dynamic "dns" {
      for_each = local.dns_configured ? [1] : []

      content {
        domain  = var.dns_domain
        servers = var.dns_servers
      }
    }

    ip_config {
      ipv4 {
        address = local.ipv4_address
        gateway = var.ip_config_gateway
      }
    }

    user_account {
      username = var.account_username
      keys     = var.ssh_public_keys
    }
  }
}
