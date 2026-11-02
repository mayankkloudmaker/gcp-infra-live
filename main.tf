locals {
  request_files = fileset(path.module, "projects/*/*.yaml")

  requests = {
    for f in local.request_files :
    yamldecode(file("${path.module}/${f}")).name => yamldecode(file("${path.module}/${f}"))
  }
}

resource "google_storage_bucket" "project" {
  for_each = local.requests

  name                        = "${var.project_id}-${each.key}"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false

  labels = {
    environment = each.value.environment
    owner       = replace(lower(each.value.owner), "/[^a-z0-9_-]/", "-")
    budget_usd  = tostring(each.value.budget_usd)
    managed_by  = "terraform"
  }
}
