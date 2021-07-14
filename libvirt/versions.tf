terraform {
  required_providers {
    drp = {
      versions = ["2.0.0"]
      source   = "extras.rackn.io/rackn/drp"
    }
  }
  required_version = ">= 0.13"
}
