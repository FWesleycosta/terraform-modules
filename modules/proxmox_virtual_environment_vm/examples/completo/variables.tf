variable "proxmox_endpoint" {
  description = "URL da API do Proxmox (ex.: https://192.168.0.10:8006/)."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^https://", var.proxmox_endpoint))
    error_message = "proxmox_endpoint deve começar com https://."
  }
}

variable "proxmox_insecure" {
  description = "Aceita o certificado autoassinado do Proxmox. Use false quando a API tiver certificado válido."
  type        = bool
  default     = true
  nullable    = false
}

variable "node_name" {
  description = "Nó do Proxmox onde as VMs de exemplo são criadas."
  type        = string
  default     = "pve"
  nullable    = false
}

variable "template_vm_id" {
  description = "ID do template com cloud-init e qemu-guest-agent que será clonado."
  type        = number
  default     = 9000
  nullable    = false
}

variable "network_bridge" {
  description = "Bridge da rede interna onde as VMs ficam."
  type        = string
  default     = "vmbr1"
  nullable    = false
}

variable "gateway" {
  description = "Gateway da rede interna (ex.: o firewall que roteia a vmbr1)."
  type        = string
  default     = "10.20.0.1"
  nullable    = false
}

variable "dns_domain" {
  description = "Domínio DNS das VMs."
  type        = string
  default     = "homelab.local"
  nullable    = false
}

variable "ssh_public_key_paths" {
  description = "Caminhos das chaves SSH públicas autorizadas nas VMs (ex.: a sua e a do bastion que roda o Ansible)."
  type        = list(string)
  default     = ["~/.ssh/id_ed25519.pub"]
  nullable    = false
}
