#######################################################################
## bigquery logging setup
#######################################################################

resource "google_bigquery_dataset" "logs_ds" {
  # bq doesnt allow hyphens in dataset names
  dataset_id = replace("${var.site_name}_ds", "-", "_")
}

resource "google_bigquery_table" "logs_table" {
  dataset_id          = google_bigquery_dataset.logs_ds.dataset_id
  table_id            = "fastly_service_logs"
  schema              = file("bqlog_schema.json")
  deletion_protection = false
}

resource "google_service_account" "bq_writer" {
  account_id = "${var.site_name}-bq-writer"
}

resource "google_project_iam_member" "bq_writer" {
  project = google_service_account.bq_writer.project
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.bq_writer.email}"
}

data "google_iam_policy" "fastly_logging_impersonation" {
  binding {
    role    = "roles/iam.serviceAccountTokenCreator"
    members = ["serviceAccount:fastly-logging@datalog-bulleit-9e86.iam.gserviceaccount.com"]
  }
}

resource "google_service_account_iam_policy" "fastly_logging_impersonation" {
  service_account_id = google_service_account.bq_writer.name
  policy_data        = data.google_iam_policy.fastly_logging_impersonation.policy_data
}