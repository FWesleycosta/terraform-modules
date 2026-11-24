mock_provider "proxmox" {}

variables {
  name            = "vm-de-teste"
  vm_id           = 150
  node_name       = "pve"
  template_vm_id  = 9000
  ssh_public_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDummyKeyParaTeste teste@homelab"]
}

# O mock não conhece o guest agent: os valores abaixo simulam o que o Proxmox devolveria.
override_resource {
  target = proxmox_virtual_environment_vm.this
  values = {
    ipv4_addresses = [["127.0.0.1"], ["10.20.0.21"]]
    mac_addresses  = ["00:00:00:00:00:00", "BC:24:11:00:00:01"]
  }
}

run "outputs_com_dhcp" {
  command = apply

  assert {
    condition     = output.id == 150
    error_message = "output.id deve ser o vm_id."
  }

  assert {
    condition     = output.name == "vm-de-teste"
    error_message = "output.name deve ser o nome da VM."
  }

  assert {
    condition     = output.node_name == "pve"
    error_message = "output.node_name deve ser o nó informado."
  }

  assert {
    condition     = output.ipv4_address == null
    error_message = "Com DHCP, output.ipv4_address deve ser null (e não o literal dhcp)."
  }

  assert {
    condition     = output.ipv4_addresses[1][0] == "10.20.0.21"
    error_message = "output.ipv4_addresses deve repassar os endereços do guest agent."
  }

  assert {
    condition     = output.mac_addresses[1] == "BC:24:11:00:00:01"
    error_message = "output.mac_addresses deve repassar os MACs da VM."
  }
}

run "outputs_com_ip_fixo" {
  command = apply

  variables {
    ipv4_address      = "10.20.0.21/24"
    ip_config_gateway = "10.20.0.1"
  }

  assert {
    condition     = output.ipv4_address == "10.20.0.21/24"
    error_message = "Com IP fixo, output.ipv4_address deve ser o endereço em CIDR."
  }
}
