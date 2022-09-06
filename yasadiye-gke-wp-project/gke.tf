terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "4.34.0"
    }
    kubernetes = {
        source = "hashicorp/kubernetes"
        version = "2.13.1"
    }
  }


}
  provider "google" {
    version = "4.34.0"
    region = "us-central1"
  }

variable "project" {default = "businesss-62a17"}
variable "region" {default = "us-central1"}
variable "cluster_name" {default = "wpbussiness"}
variable "network" {default = "default"}
variable "subnetwork" {default = ""}
variable "ip_range_pods" {default = ""}
variable "ip_range_services" {default = ""}

module "gke" {
    source = "terraform-google-modules/kubernetes-engine/google"
    version = "23.0.0"
    project_id = var.project
    name = var.cluster_name
    region = var.region
    zones = ["us-central1-c"]
    network = var.network
    subnetwork = var.subnetwork
    ip_range_pods = var.ip_range_pods
    ip_range_services = var.ip_range_services
    kubernetes_version = "1.22.11-gke.400"
    create_service_account = false
    remove_default_node_pool = true

    node_pools = [{
        name = "microservices"
        machine_type = "n1-standard-1"
        min_count = 1
        max_count = 5
        initial_node_count = 2
    }]

    node_pools_oauth_scopes = {
        all = []
        microservices = [
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring"
        ]
    }
}


data "google_client_config" "current" {}

provider "kubernetes" {
    ##config_file = false


    host = "https://${module.gke.endpoint}"
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
    token = data.google_client_config.current.access_token

}



