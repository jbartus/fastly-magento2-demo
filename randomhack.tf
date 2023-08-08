resource "google_service_account" "random_hacker" {
  account_id = "${var.site_name}-random-hacker"
}

resource "google_project_iam_member" "random_hacker" {
  project = google_service_account.random_hacker.project
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.random_hacker.email}"
}

resource "google_compute_instance" "random_hacker_instance" {
  name                      = "${var.site_name}-random-hacker"
  machine_type              = "c3-standard-4"
  tags                      = ["https-server"]
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2304-amd64"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  service_account {
    email  = google_service_account.random_hacker.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata_startup_script = <<SCRIPT
curl -fsSL https://get.docker.com | sh
gcloud auth configure-docker --quiet
docker run --network host -d gcr.io/${google_project_iam_member.random_hacker.project}/random-hack@${var.rhack_digest} /usr/src/app/main -target https://${var.site_name}.global.ssl.fastly.net -debugging 1
SCRIPT
}