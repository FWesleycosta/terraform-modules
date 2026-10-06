resource "aws_s3_bucket" "this" {
  bucket        = var.name
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    # Desativa ACLs: o dono do bucket é dono de todos os objetos.
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encryption.sse_algorithm
      kms_master_key_id = var.encryption.kms_key_arn
    }

    bucket_key_enabled       = var.encryption.sse_algorithm == "AES256" ? null : var.encryption.bucket_key_enabled
    blocked_encryption_types = ["SSE-C"]
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json

  # Com o bloqueio aplicado antes, uma policy pública é rejeitada pela AWS.
  depends_on = [aws_s3_bucket_public_access_block.this]
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  # Singleton opcional: o S3 aceita uma única configuração de lifecycle por bucket.
  count = length(local.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = local.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      filter {
        prefix                   = rule.value.filter_criteria == 1 ? rule.value.filter.prefix : null
        object_size_greater_than = rule.value.filter_criteria == 1 ? rule.value.filter.object_size_greater_than : null
        object_size_less_than    = rule.value.filter_criteria == 1 ? rule.value.filter.object_size_less_than : null

        dynamic "tag" {
          for_each = rule.value.filter_criteria == 1 ? rule.value.filter.tags : {}

          content {
            key   = tag.key
            value = tag.value
          }
        }

        dynamic "and" {
          for_each = rule.value.filter_criteria > 1 ? [rule.value.filter] : []

          content {
            prefix                   = and.value.prefix
            tags                     = length(and.value.tags) > 0 ? and.value.tags : null
            object_size_greater_than = and.value.object_size_greater_than
            object_size_less_than    = and.value.object_size_less_than
          }
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload_days == null ? [] : [rule.value.abort_incomplete_multipart_upload_days]

        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration == null ? [] : [rule.value.expiration]

        content {
          days                         = expiration.value.days
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions

        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration == null ? [] : [rule.value.noncurrent_version_expiration]

        content {
          noncurrent_days           = noncurrent_version_expiration.value.noncurrent_days
          newer_noncurrent_versions = noncurrent_version_expiration.value.newer_noncurrent_versions
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions

        content {
          noncurrent_days           = noncurrent_version_transition.value.noncurrent_days
          storage_class             = noncurrent_version_transition.value.storage_class
          newer_noncurrent_versions = noncurrent_version_transition.value.newer_noncurrent_versions
        }
      }
    }
  }

  # A AWS recomenda configurar o versionamento antes das regras de lifecycle.
  depends_on = [aws_s3_bucket_versioning.this]
}

check "force_destroy" {
  assert {
    condition     = !var.force_destroy
    error_message = "force_destroy está ligado: um destroy apaga o bucket e todos os objetos e versões sem confirmação."
  }
}

check "versionamento" {
  assert {
    condition     = var.versioning_enabled
    error_message = "O versionamento está suspenso: objetos sobrescritos ou apagados não poderão ser recuperados."
  }
}
