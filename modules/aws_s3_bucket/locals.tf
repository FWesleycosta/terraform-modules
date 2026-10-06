locals {
  # O filter do lifecycle aceita no máximo um critério direto; com mais de um,
  # os critérios precisam ir dentro de um bloco "and".
  lifecycle_rules = [
    for r in var.lifecycle_rules : merge(r, {
      filter_criteria = (
        (r.filter.prefix != null ? 1 : 0) +
        length(r.filter.tags) +
        (r.filter.object_size_greater_than != null ? 1 : 0) +
        (r.filter.object_size_less_than != null ? 1 : 0)
      )
    })
  ]
}
