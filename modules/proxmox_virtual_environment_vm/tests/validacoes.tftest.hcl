mock_provider "proxmox" {}

variables {
  name            = "vm-de-teste"
  vm_id           = 150
  node_name       = "pve"
  template_vm_id  = 9000
  ssh_public_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDummyKeyParaTeste teste@homelab"]
}

run "nome_com_maiuscula" {
  command = plan
  variables {
    name = "VM-De-Teste"
  }
  expect_failures = [var.name]
}

run "nome_terminando_em_hifen" {
  command = plan
  variables {
    name = "vm-de-teste-"
  }
  expect_failures = [var.name]
}

run "vm_id_reservado" {
  command = plan
  variables {
    vm_id = 99
  }
  expect_failures = [var.vm_id]
}

run "vm_id_fracionado" {
  command = plan
  variables {
    vm_id = 150.5
  }
  expect_failures = [var.vm_id]
}

run "node_name_vazio" {
  command = plan
  variables {
    node_name = "  "
  }
  expect_failures = [var.node_name]
}

run "template_vm_id_reservado" {
  command = plan
  variables {
    template_vm_id = 50
  }
  expect_failures = [var.template_vm_id]
}

run "cores_zero" {
  command = plan
  variables {
    cores = 0
  }
  expect_failures = [var.cores]
}

run "memoria_abaixo_do_minimo" {
  command = plan
  variables {
    memory_mb = 256
  }
  expect_failures = [var.memory_mb]
}

run "disco_zero" {
  command = plan
  variables {
    disk_size_gb = 0
  }
  expect_failures = [var.disk_size_gb]
}

run "datastore_vazio" {
  command = plan
  variables {
    datastore_id = ""
  }
  expect_failures = [var.datastore_id]
}

run "bridge_vazia" {
  command = plan
  variables {
    network_bridge = ""
  }
  expect_failures = [var.network_bridge]
}

run "ip_sem_prefixo" {
  command = plan
  variables {
    ipv4_address      = "10.20.0.21"
    ip_config_gateway = "10.20.0.1"
  }
  expect_failures = [var.ipv4_address]
}

run "ip_fora_da_faixa" {
  command = plan
  variables {
    ipv4_address      = "10.20.0.300/24"
    ip_config_gateway = "10.20.0.1"
  }
  expect_failures = [var.ipv4_address]
}

run "gateway_invalido" {
  command = plan
  variables {
    ipv4_address      = "10.20.0.21/24"
    ip_config_gateway = "10.20.0"
  }
  expect_failures = [var.ip_config_gateway]
}

run "ip_fixo_sem_gateway" {
  command = plan
  variables {
    ipv4_address = "10.20.0.21/24"
  }
  expect_failures = [var.ip_config_gateway]
}

run "gateway_com_dhcp" {
  command = plan
  variables {
    ip_config_gateway = "10.20.0.1"
  }
  expect_failures = [var.ip_config_gateway]
}

run "dominio_invalido" {
  command = plan
  variables {
    dns_domain = "-homelab.local"
  }
  expect_failures = [var.dns_domain]
}

run "dns_server_invalido" {
  command = plan
  variables {
    dns_servers = ["10.20.0.1", "dns.homelab.local"]
  }
  expect_failures = [var.dns_servers]
}

run "usuario_invalido" {
  command = plan
  variables {
    account_username = "Ubuntu"
  }
  expect_failures = [var.account_username]
}

run "sem_chaves" {
  command = plan
  variables {
    ssh_public_keys = []
  }
  expect_failures = [var.ssh_public_keys]
}

run "chave_privada_no_lugar_da_publica" {
  command = plan
  variables {
    ssh_public_keys = ["-----BEGIN OPENSSH PRIVATE KEY-----"]
  }
  expect_failures = [var.ssh_public_keys]
}

run "tag_chave_valor" {
  command = plan
  variables {
    tags = ["env=lab"]
  }
  expect_failures = [var.tags]
}
