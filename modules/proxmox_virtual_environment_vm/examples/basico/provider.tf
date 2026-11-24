# O token vem do ambiente, nunca de variável ou .tfvars:
#   PROXMOX_VE_API_TOKEN="usuario@pve!token=uuid"
provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure
}
