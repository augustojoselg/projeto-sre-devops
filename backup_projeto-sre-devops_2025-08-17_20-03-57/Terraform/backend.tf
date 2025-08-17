terraform {
  backend "gcs" {
    bucket = "augustosredevops-tfstate" # IMPORTANTE: Crie este bucket manualmente!
    prefix = "terraform/state"
  }
}
