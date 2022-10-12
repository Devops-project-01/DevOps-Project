# define GCP region
variable "gcp_region" {
  type        = string
  description = "GCP region"
}
# define GCP project name
variable "gcp_project" {
  type        = string
  description = "GCP project name"
}
variable "bucket-name" {
  type        = string
  description = "The name of the Google Storage Bucket to create"
}
variable "gce_ssh_pub_key_file" {
  type        = string
  description = "public key path"
}
