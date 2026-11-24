output "vm_ids" {
  description = "ID de cada VM, por nome."
  value       = { for name, vm in module.proxmox_virtual_environment_vm : name => vm.id }
}

output "ipv4_addresses" {
  description = "IP fixo de cada VM, por nome (pronto para um inventário do Ansible)."
  value       = { for name, vm in module.proxmox_virtual_environment_vm : name => split("/", vm.ipv4_address)[0] }
}
