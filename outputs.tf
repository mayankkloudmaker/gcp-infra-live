output "bucket_names" {
  description = "Buckets created per project request"
  value       = { for k, b in google_storage_bucket.project : k => b.name }
}
