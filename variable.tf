variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type        = string
  default = "probable-pager-452507-d4"
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

# Optional: You can add more variables as needed
