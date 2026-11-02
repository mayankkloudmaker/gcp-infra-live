variable "project_id" {
  description = "GCP project where lab resources are created"
  type        = string
}

variable "region" {
  description = "Default region"
  type        = string
  default     = "asia-south1"
}
