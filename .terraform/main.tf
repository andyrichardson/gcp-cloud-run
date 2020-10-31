provider "google" {
  project = "trying-serverless"
  region  = "europe-west2"
  zone    = "europe-west2-a"
}

# Setup cloud run service
resource "google_cloud_run_service" "hello" {
  name     = "cloudrun-hello"
  location = "europe-west2"

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Get policy for all users to access
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

# Set policy on cloud service
resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.hello.location
  project  = google_cloud_run_service.hello.project
  service  = google_cloud_run_service.hello.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
