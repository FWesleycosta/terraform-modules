# Duas VMs com IP fixo na rede interna, DNS próprio, guest agent ligado,
# tamanhos e tags por VM e mais de uma chave SSH autorizada.

module "proxmox_virtual_environment_vm" {
  source   = "../.."
  for_each = local.vms

  name           = each.key
  vm_id          = each.value.vm_id
  node_name      = var.node_name
  template_vm_id = var.template_vm_id

  cores        = each.value.cores
  memory_mb    = each.value.memory_mb
  disk_size_gb = 30
  datastore_id = "local-lvm"

  network_bridge    = var.network_bridge
  ipv4_address      = each.value.ipv4_address
  ip_config_gateway = var.gateway
  dns_domain        = var.dns_domain
  dns_servers       = [var.gateway]

  account_username = "ubuntu"
  ssh_public_keys  = local.ssh_public_keys

  # O template precisa ter o qemu-guest-agent instalado; sem ele, o apply fica esperando.
  agent_enabled = true

  tags = each.value.tags
}
