terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "5.6.0"
    }
  }
}

provider "google" {
 credentials    = file(var.credentials)
 project        = var.project_id
 region         = var.region 
}

resource "google_storage_bucket" "terraform-bucket" {
  name = var.gcs_bucket_name
  location = var.location
  storage_class = var.gcs_bucket_class
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_bigquery_dataset" "terraform-dataset" {
  dataset_id = var.bq_dataset_name
  location = var.location
  delete_contents_on_destroy = true
}
