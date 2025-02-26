variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type        = string
  default = "cts05-murgod"
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

# Optional: You can add more variables as needed
