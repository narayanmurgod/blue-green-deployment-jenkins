terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.36.0, < 5.0.0"  # Use a compatible version
    }
  }
}
provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC Network Configuration
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.0"

  project_id   = var.project_id
  network_name = "gke-vpc"
  auto_create_subnetworks = false

  subnets = [
    {
      subnet_name           = "gke-subnet"
      subnet_ip             = "10.10.0.0/16"
      subnet_region         = var.region
      subnet_private_access = true
      subnet_flow_logs      = true
    }
  ]

  secondary_ranges = {
    "gke-subnet" = [
      {
        range_name    = "pod-range"
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = "service-range"
        ip_cidr_range = "10.30.0.0/16"
      }
    ]
  }
}

# GKE Cluster Configuration
module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "~> 27.0"

  project_id               = var.project_id
  name                     = "main-cluster"
  regional                 = true
  region                   = var.region
  network                  = module.vpc.network_name
  subnetwork               = module.vpc.subnets["${var.region}/gke-subnet"].name
  ip_range_pods            = "pod-range"
  ip_range_services        = "service-range"
  
  # Cluster security/config
  enable_private_endpoint  = false
  enable_private_nodes     = true
  master_ipv4_cidr_block   = "172.16.0.0/28"
  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "public-access"
    }
  ]

  # Node Pools Configuration
  remove_default_node_pool = true
  node_pools = [
    {
      name               = "primary-node-pool"
      machine_type       = "e2-medium"
      min_count          = 1
      max_count          = 5
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
      initial_node_count = 1
      

    },
    {
      name               = "secondary-node-pool"
      machine_type       = "e2-small"
      min_count          = 1
      max_count          = 5
      disk_size_gb       = 100
      disk_type          = "pd-ssd"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = true
      initial_node_count = 1
     
    }
  ]

  node_pools_tags = {
    "primary-node-pool"   = ["primary-pool"]
    "secondary-node-pool" = ["secondary-pool"]
  }

  depends_on = [
    module.vpc
  ]
}
