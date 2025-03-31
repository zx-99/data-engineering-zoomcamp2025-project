output "bucket_name" {
  value = google_storage_bucket.terraform-bucket.name
}

output "bigquery_dataset_name" {
  value = google_bigquery_dataset.terraform-dataset
}