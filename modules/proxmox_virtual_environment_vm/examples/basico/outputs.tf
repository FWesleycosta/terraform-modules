output "vm_id" {
  description = "ID da VM criada."
  value       = module.proxmox_virtual_environment_vm.id
}

output "mac_addresses" {
  description = "MACs da VM, para achar o IP que o DHCP entregou."
  value       = module.proxmox_virtual_environment_vm.mac_addresses
}
