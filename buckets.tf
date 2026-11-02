locals {
  bucket_files = fileset(path.module, "buckets/*/*.yaml")

  bucket_requests = {
    for f in local.bucket_files :
    yamldecode(file("${path.module}/${f}")).name => yamldecode(file("${path.module}/${f}"))
  }
}

resource "google_storage_bucket" "requested" {
  for_each = local.bucket_requests

  name                        = "${var.project_id}-${each.key}"
  location                    = each.value.location
  storage_class               = each.value.storage_class
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = each.value.versioning
  }

  lifecycle_rule {
    condition {
      age = each.value.delete_after_days
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = each.value.environment
    owner       = replace(lower(each.value.owner), "/[^a-z0-9_-]/", "-")
    managed_by  = "backstage-terraform"
  }
}

output "requested_buckets" {
  description = "Buckets created from Backstage bucket requests"
  value       = { for k, b in google_storage_bucket.requested : k => b.url }
}
