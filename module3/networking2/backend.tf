##################################################################################
# BACKENDS
##################################################################################
terraform {
  backend "consul" {
    key = "networking.state"
    region = "us-east-1"
  }
}

tags {
  Name = "networking-state"
  State-Backend = "Consul"
  Environment = "dev"
}