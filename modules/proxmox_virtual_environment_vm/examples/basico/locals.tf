locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}
