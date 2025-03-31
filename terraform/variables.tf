variable "credentials" {
  description = "My Credentials"
  type = string
}

variable "project_id" {
  description = "Project ID"
  type = string
}

variable "region" {
  description = "Region"
  type = string
}

variable "location" {
  description = "Project Location"
  type = string
}

variable "gcs_bucket_name" {
  description = "Stroage Bucket Name"
  type = string
}

variable "gcs_bucket_class" {
  description = "Bucket Storage Class"
  type = string
}

variable "bq_dataset_name" {
  description = "BigQuery Dataset(Schema) Name"
  type = string
}