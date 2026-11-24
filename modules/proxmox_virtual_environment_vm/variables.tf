variable "name" {
  description = "Nome da VM e hostname do convidado. Até 63 caracteres: minúsculas, números e hífens, sem começar nem terminar com hífen."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.name))
    error_message = "name deve ser um hostname válido: minúsculas, números e hífens, até 63 caracteres, sem começar nem terminar com hífen."
  }
}

variable "vm_id" {
  description = "ID da VM no Proxmox."
  type        = number
  nullable    = false

  validation {
    condition     = var.vm_id >= 100 && floor(var.vm_id) == var.vm_id
    error_message = "vm_id deve ser um inteiro a partir de 100 (o Proxmox reserva os IDs abaixo de 100)."
  }
}

variable "node_name" {
  description = "Nó do Proxmox que hospeda a VM."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.node_name)) > 0
    error_message = "node_name não pode ser vazio."
  }
}

variable "template_vm_id" {
  description = "ID do template que será clonado (clone completo). O template precisa ter cloud-init."
  type        = number
  nullable    = false

  validation {
    condition     = var.template_vm_id >= 100 && floor(var.template_vm_id) == var.template_vm_id
    error_message = "template_vm_id deve ser um inteiro a partir de 100."
  }
}

variable "cores" {
  description = "Quantidade de vCPUs."
  type        = number
  default     = 2
  nullable    = false

  validation {
    condition     = var.cores >= 1 && floor(var.cores) == var.cores
    error_message = "cores deve ser um inteiro a partir de 1."
  }
}

variable "memory_mb" {
  description = "Memória em MB."
  type        = number
  default     = 2048
  nullable    = false

  validation {
    condition     = var.memory_mb >= 512 && floor(var.memory_mb) == var.memory_mb
    error_message = "memory_mb deve ser um inteiro a partir de 512."
  }
}

variable "disk_size_gb" {
  description = "Tamanho do disco em GB. Não pode ser menor que o disco do template, porque o Proxmox não encolhe o disco do clone."
  type        = number
  default     = 20
  nullable    = false

  validation {
    condition     = var.disk_size_gb > 0 && floor(var.disk_size_gb) == var.disk_size_gb
    error_message = "disk_size_gb deve ser um inteiro maior que 0."
  }
}

variable "datastore_id" {
  description = "Datastore do Proxmox onde fica o disco da VM."
  type        = string
  default     = "local-lvm"
  nullable    = false

  validation {
    condition     = length(trimspace(var.datastore_id)) > 0
    error_message = "datastore_id não pode ser vazio."
  }
}

variable "network_bridge" {
  description = "Bridge do Proxmox ligada à placa de rede da VM."
  type        = string
  default     = "vmbr0"
  nullable    = false

  validation {
    condition     = length(trimspace(var.network_bridge)) > 0
    error_message = "network_bridge não pode ser vazio."
  }
}

variable "ipv4_address" {
  description = "Endereço IPv4 fixo com o prefixo (ex.: 10.20.0.21/24). Com null, a VM pega o IP por DHCP."
  type        = string
  default     = null

  validation {
    condition     = var.ipv4_address == null || (can(regex("^(\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", var.ipv4_address)) && can(cidrhost(var.ipv4_address, 0)))
    error_message = "ipv4_address deve ser null (DHCP) ou um IPv4 com prefixo, como 10.20.0.21/24."
  }
}

variable "ip_config_gateway" {
  description = "Gateway IPv4 da VM. Obrigatório quando ipv4_address é fixo; com DHCP, deixe null."
  type        = string
  default     = null

  validation {
    condition     = var.ip_config_gateway == null || can(cidrhost("${var.ip_config_gateway}/32", 0))
    error_message = "ip_config_gateway deve ser um endereço IPv4 válido."
  }

  validation {
    condition     = (var.ipv4_address == null) == (var.ip_config_gateway == null)
    error_message = "ip_config_gateway deve ser informado junto com ipv4_address fixo, e deve ser null com DHCP."
  }
}

variable "dns_domain" {
  description = "Domínio DNS da VM. Com null, herda o do host Proxmox."
  type        = string
  default     = null

  validation {
    condition     = var.dns_domain == null || can(regex("^[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?$", var.dns_domain))
    error_message = "dns_domain deve ser um nome de domínio válido."
  }
}

variable "dns_servers" {
  description = "Servidores DNS da VM. Com null, herda os do host Proxmox."
  type        = list(string)
  default     = null

  validation {
    condition     = var.dns_servers == null || alltrue([for server in coalesce(var.dns_servers, []) : can(cidrhost("${server}/32", 0))])
    error_message = "dns_servers deve conter só endereços IPv4 válidos."
  }
}

variable "account_username" {
  description = "Usuário criado pelo cloud-init na VM."
  type        = string
  default     = "ubuntu"
  nullable    = false

  validation {
    condition     = can(regex("^[a-z_][a-z0-9_-]{0,31}$", var.account_username))
    error_message = "account_username deve ser um usuário Linux válido: minúsculas, números, _ e -, até 32 caracteres, começando por letra ou _."
  }
}

variable "ssh_public_keys" {
  description = "Chaves SSH públicas autorizadas para o usuário do cloud-init."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.ssh_public_keys) > 0
    error_message = "ssh_public_keys precisa de pelo menos uma chave, senão não há como acessar a VM."
  }

  validation {
    condition     = alltrue([for key in var.ssh_public_keys : can(regex("^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp(256|384|521)) ", key))])
    error_message = "Cada item de ssh_public_keys deve ser uma chave pública OpenSSH (ssh-ed25519, ssh-rsa ou ecdsa-sha2-*)."
  }
}

variable "agent_enabled" {
  description = "Liga o QEMU guest agent. Só use true se a imagem do template tiver o qemu-guest-agent instalado, senão o Terraform fica esperando o agente responder."
  type        = bool
  default     = false
  nullable    = false
}

variable "tags" {
  description = "Tags da VM no Proxmox. O Proxmox só aceita tags simples (sem chave=valor)."
  type        = list(string)
  default     = ["terraform"]
  nullable    = false

  validation {
    condition     = alltrue([for tag in var.tags : can(regex("^[a-z0-9_.+-]+$", tag))])
    error_message = "tags deve usar só minúsculas, números e os caracteres _ . + -."
  }
}
