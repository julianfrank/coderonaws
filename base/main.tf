//Providers
provider "aws" {
  access_key  = "${var.aws_access_key}"
  secret_key  = "${var.aws_secret_key}"
  region      = "${var.region}"
  version     = "~> 2.2"
}

provider "null" {
  version = "~> 2.1"
}

//VPC
resource "aws_vpc" "vpc_coder_on_aws" {
    assign_generated_ipv6_cidr_block  = "false"
    enable_dns_hostnames              = "true"
    enable_dns_support                = "true"
    cidr_block                        = "${var.cidr_ipv4}"
    tags                              = {Name = "vpc_coder_on_aws"}
}

