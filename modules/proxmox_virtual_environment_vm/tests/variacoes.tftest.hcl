mock_provider "proxmox" {}

variables {
  name            = "vm-de-teste"
  vm_id           = 150
  node_name       = "pve"
  template_vm_id  = 9000
  ssh_public_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDummyKeyParaTeste teste@homelab"]
}

run "ip_fixo" {
  command = plan

  variables {
    ipv4_address      = "10.20.0.21/24"
    ip_config_gateway = "10.20.0.1"
  }

  assert {
    condition = (
      proxmox_virtual_environment_vm.this.initialization[0].ip_config[0].ipv4[0].address == "10.20.0.21/24" &&
      proxmox_virtual_environment_vm.this.initialization[0].ip_config[0].ipv4[0].gateway == "10.20.0.1"
    )
    error_message = "Com IP fixo, o cloud-init deve receber o endereço e o gateway informados."
  }
}

run "dns_so_servidores" {
  command = plan

  variables {
    dns_servers = ["10.20.0.1", "1.1.1.1"]
  }

  assert {
    condition     = length(proxmox_virtual_environment_vm.this.initialization[0].dns) == 1
    error_message = "Com dns_servers, o bloco dns deve ser criado."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.initialization[0].dns[0].servers == tolist(["10.20.0.1", "1.1.1.1"])
    error_message = "Os servidores DNS devem ser os informados, na mesma ordem."
  }
}

run "dns_so_dominio" {
  command = plan

  variables {
    dns_domain = "homelab.local"
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.initialization[0].dns[0].domain == "homelab.local"
    error_message = "Com dns_domain, o bloco dns deve receber o domínio."
  }
}

run "agent_ligado" {
  command = plan

  variables {
    agent_enabled = true
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.agent[0].enabled == true
    error_message = "agent_enabled = true deve ligar o guest agent."
  }
}

run "tamanhos_e_rede" {
  command = plan

  variables {
    cores          = 4
    memory_mb      = 8192
    disk_size_gb   = 50
    datastore_id   = "local-zfs"
    network_bridge = "vmbr1"
  }

  assert {
    condition = (
      proxmox_virtual_environment_vm.this.cpu[0].cores == 4 &&
      proxmox_virtual_environment_vm.this.memory[0].dedicated == 8192 &&
      proxmox_virtual_environment_vm.this.disk[0].size == 50
    )
    error_message = "CPU, memória e disco devem respeitar os valores informados."
  }

  assert {
    condition = (
      proxmox_virtual_environment_vm.this.disk[0].datastore_id == "local-zfs" &&
      proxmox_virtual_environment_vm.this.initialization[0].datastore_id == "local-zfs"
    )
    error_message = "O disco e o drive do cloud-init devem ir para o datastore informado."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.network_device[0].bridge == "vmbr1"
    error_message = "A placa de rede deve usar a bridge informada."
  }
}

run "usuario_chaves_e_tags" {
  command = plan

  variables {
    account_username = "ansible"
    ssh_public_keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDummyKeyParaTeste teste@homelab",
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDummy bastion@homelab",
    ]
    tags = ["k8s", "worker"]
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.initialization[0].user_account[0].username == "ansible"
    error_message = "O usuário do cloud-init deve ser o informado."
  }

  assert {
    condition     = length(proxmox_virtual_environment_vm.this.initialization[0].user_account[0].keys) == 2
    error_message = "Todas as chaves SSH devem ser autorizadas."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.tags == tolist(["k8s", "worker"])
    error_message = "As tags informadas devem substituir o padrão."
  }
}
