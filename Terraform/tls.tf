# terraform {
#   required_providers {
#     tls = {
#       source  = "hashicorp/tls"
#       version = "3.1.0"
#     }
#   }
# }

# provider "tls" {
#   // no config needed
# }

# resource "tls_private_key" "ssh" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "local_file" "ssh_private_key_pem" {
#   content         = tls_private_key.ssh.private_key_pem
#   filename        = "../../.ssh/google_compute_engine"
#   file_permission = "0600"
# }

# resource "local_file" "ssh_public_key_pem" {
#   content         = tls_private_key.ssh.public_key_openssh
#   filename        = "../../.ssh/google_compute_engine.pub"
#   file_permission = "0600"
# }