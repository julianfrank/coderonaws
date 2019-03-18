variable "aws_access_key" {
  default     = ""
  description = "Amazon AWS Access Key"
}
variable "aws_secret_key" {
  default     = ""
  description = "Amazon AWS Secret Key"
}
variable "region" {
  default     = "us-west-2"
  description = "Amazon AWS Region for deployment"
}
variable "cidr_ipv4" {
  description = "CIDR for IPV4"
  default = "10.0.0.0/16"
}
variable "prefix" {
  description = "Prefix to be used in all resources for this project"
  default = "coder_on_aws"
}