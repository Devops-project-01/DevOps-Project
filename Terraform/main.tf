terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

provider "tls" {
  // no config needed
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "../../.ssh/google_compute_engine"
  file_permission = "0600"
}

resource "local_file" "ssh_public_key_pem" {
  content         = tls_private_key.ssh.public_key_openssh
  filename        = "../../.ssh/google_compute_engine.pub"
  file_permission = "0600"
}

provider "google" {
  project = "gcp-testo1"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_project_service" "cloud_resource_manager" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}
resource "google_compute_address" "static_ip" {
  name = "terraform-created-vm"
}

data "google_client_openid_userinfo" "me" {}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance-1"
  machine_type = "e2-micro"
  tags         = ["allow-ssh"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-pro-cloud/ubuntu-pro-2004-lts"
    }
  }
  metadata = {
    # ssh-keys = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.ssh.public_key_openssh}"
    ssh-keys = "root:${tls_private_key.ssh.public_key_openssh}"
  }

  network_interface {
    # A default network is created for all GCP projects
    network    = google_compute_network.custom-test.self_link
    subnetwork = google_compute_subnetwork.network-1.self_link
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }
}
resource "google_compute_instance" "vm_instance-2" {
  name         = "terraform-instance-2"
  machine_type = "e2-micro"
  tags         = ["allow-ssh"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-pro-cloud/ubuntu-pro-2004-lts"
    }
  }
  metadata = {
    # ssh-keys = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.ssh.public_ke>
    ssh-keys = "root:${tls_private_key.ssh.public_key_openssh}"
  }

  network_interface {
    # A default network is created for all GCP projects
    network    = google_compute_network.custom-test.self_link
    subnetwork = google_compute_subnetwork.network-1.self_link
    access_config {
    }
  }
}

resource "google_compute_subnetwork" "network-1" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.custom-test.id
}

resource "google_compute_firewall" "ansible-fw-1" {
  name          = "test-firewall"
  network       = google_compute_network.custom-test.name
  target_tags   = ["allow-ssh"]
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "22"]
  }
}

resource "google_compute_network" "custom-test" {
  name                    = "test-network"
  auto_create_subnetworks = false
}
resource "null_resource" "example2" {
provisioner "local-exec" {
  command = "ansible -i ./../../inventory/hosts.ini remote -m ping > ansible_out"
}
}

resource "local_file" "inventory" {
  filename = "./../../inventory/hosts.ini"
file_permission= "0644"  
content  = <<EOF
[webserver]
${google_compute_instance.vm_instance.network_interface.0.network_ip}
localhost
${google_compute_instance.vm_instance-2.network_interface.0.access_config.0.nat_ip}
[remote]
${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}
${google_compute_instance.vm_instance-2.network_interface.0.access_config.0.nat_ip}
EOF
}

output "public_ip" {
  value = google_compute_address.static_ip.address
}

