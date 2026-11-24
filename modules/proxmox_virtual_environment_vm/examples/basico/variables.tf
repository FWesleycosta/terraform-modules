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
  description = "Nó do Proxmox onde a VM de exemplo é criada."
  type        = string
  default     = "pve"
  nullable    = false
}

variable "template_vm_id" {
  description = "ID do template com cloud-init que será clonado."
  type        = number
  default     = 9000
  nullable    = false
}

variable "ssh_public_key_path" {
  description = "Caminho da chave SSH pública autorizada na VM."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
  nullable    = false
}
