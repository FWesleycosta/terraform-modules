locals {
  # O cloud-init do Proxmox usa o literal "dhcp" quando não há IP fixo.
  ipv4_address = coalesce(var.ipv4_address, "dhcp")

  # Só gera o bloco dns quando há algo a sobrescrever; sem ele, a VM herda o DNS do host.
  dns_configured = var.dns_domain != null || var.dns_servers != null
}
