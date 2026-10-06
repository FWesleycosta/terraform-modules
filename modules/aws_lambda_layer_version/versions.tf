terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Todos os argumentos usados existem antes da 6.0 (piso do monorepo).
      # Runtimes recentes dependem da versão do provider do consumidor:
      # nodejs24.x, python3.14 e java25 a partir da 6.21; ruby4.0 a partir da 6.45.
      version = ">= 6.0"
    }
  }
}
