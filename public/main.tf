//Providers
provider "aws" {
  access_key  = "${var.aws_access_key}"
  secret_key  = "${var.aws_secret_key}"
  region      = "${var.region}"
  version     = "~> 2.2"
}
data "aws_vpc" "vpc_coder_on_aws" {
  filter{
    name    = "tag:Name"
    values  = ["vpc_coder_on_aws"]
  }
}