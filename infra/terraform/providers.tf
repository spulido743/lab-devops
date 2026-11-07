provider "aws" {
  region = var.region

  default_tags {
    tags = {
      proyecto   = "lab-devops"
      ambiente   = "lab"
      creado-por = "terraform"
    }
  }
}
