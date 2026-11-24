# VM com os defaults do módulo: 2 vCPUs, 2048 MB, disco de 20 GB no local-lvm,
# rede na vmbr0 com IP por DHCP e DNS herdado do host.

module "proxmox_virtual_environment_vm" {
  source = "../.."

  name            = "exemplo-basico"
  vm_id           = 900
  node_name       = var.node_name
  template_vm_id  = var.template_vm_id
  ssh_public_keys = [local.ssh_public_key]
}
