mock_provider "proxmox" {}

variables {
  name            = "vm-de-teste"
  vm_id           = 150
  node_name       = "pve"
  template_vm_id  = 9000
  ssh_public_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDummyKeyParaTeste teste@homelab"]
}

run "defaults" {
  command = plan

  assert {
    condition     = proxmox_virtual_environment_vm.this.name == "vm-de-teste" && proxmox_virtual_environment_vm.this.vm_id == 150
    error_message = "A VM deve usar o name e o vm_id informados."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.clone[0].vm_id == 9000 && proxmox_virtual_environment_vm.this.clone[0].full == true
    error_message = "A VM deve ser um clone completo do template informado."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.cpu[0].cores == 2 && proxmox_virtual_environment_vm.this.cpu[0].type == "host"
    error_message = "Por padrão a VM deve ter 2 vCPUs do tipo host."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.memory[0].dedicated == 2048
    error_message = "Por padrão a VM deve ter 2048 MB de memória."
  }

  assert {
    condition = (
      proxmox_virtual_environment_vm.this.disk[0].size == 20 &&
      proxmox_virtual_environment_vm.this.disk[0].datastore_id == "local-lvm" &&
      proxmox_virtual_environment_vm.this.disk[0].interface == "scsi0"
    )
    error_message = "Por padrão o disco deve ter 20 GB no local-lvm, em scsi0."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.network_device[0].bridge == "vmbr0" && proxmox_virtual_environment_vm.this.network_device[0].model == "virtio"
    error_message = "Por padrão a placa de rede deve ser virtio na vmbr0."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.initialization[0].ip_config[0].ipv4[0].address == "dhcp"
    error_message = "Sem ipv4_address, o cloud-init deve usar DHCP."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.initialization[0].ip_config[0].ipv4[0].gateway == null
    error_message = "Com DHCP, não deve haver gateway fixo."
  }

  assert {
    condition     = length(proxmox_virtual_environment_vm.this.initialization[0].dns) == 0
    error_message = "Sem dns_domain e dns_servers, o bloco dns não deve existir (herda do host)."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.initialization[0].user_account[0].username == "ubuntu"
    error_message = "Por padrão o usuário do cloud-init deve ser ubuntu."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.agent[0].enabled == false
    error_message = "Por padrão o guest agent deve estar desligado."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.tags == tolist(["terraform"])
    error_message = "Por padrão a VM deve ter só a tag terraform."
  }
}
