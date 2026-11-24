output "id" {
  description = "ID da VM no Proxmox (o mesmo valor de vm_id)."
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  description = "Nome da VM."
  value       = proxmox_virtual_environment_vm.this.name
}

output "node_name" {
  description = "Nó do Proxmox onde a VM está."
  value       = proxmox_virtual_environment_vm.this.node_name
}

output "ipv4_address" {
  description = "Endereço IPv4 fixo configurado no cloud-init, em notação CIDR, ou null quando a VM usa DHCP."
  value       = var.ipv4_address
}

output "ipv4_addresses" {
  description = "Endereços IPv4 informados pelo QEMU guest agent, uma lista por interface. Fica vazio quando agent_enabled é false."
  value       = proxmox_virtual_environment_vm.this.ipv4_addresses
}

output "mac_addresses" {
  description = "Endereços MAC das interfaces de rede, na ordem dos network_device."
  value       = proxmox_virtual_environment_vm.this.mac_addresses
}
