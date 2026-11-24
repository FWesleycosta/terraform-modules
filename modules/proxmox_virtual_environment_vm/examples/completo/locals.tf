locals {
  ssh_public_keys = [for path in var.ssh_public_key_paths : trimspace(file(pathexpand(path)))]

  # Uma entrada por VM: a chave do mapa vira o nome, e o for_each mantém a
  # identidade de cada VM mesmo quando outra é removida do mapa.
  vms = {
    "exemplo-cp1" = {
      vm_id        = 910
      ipv4_address = "10.20.0.91/24"
      cores        = 2
      memory_mb    = 4096
      tags         = ["exemplo", "control-plane"]
    }
    "exemplo-worker1" = {
      vm_id        = 911
      ipv4_address = "10.20.0.92/24"
      cores        = 2
      memory_mb    = 3072
      tags         = ["exemplo", "worker"]
    }
  }
}
