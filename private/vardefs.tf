variable "ec2_ami" {
  default=       "ami-0385455dc2b1498ef"     
}
variable "nat_ami" {
  default=       "ami-0b840e8a1ce4cdf15"     
}
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

variable "type" {
  default     = "t2.micro"
  description = "Amazon AWS Instance Type"
}
variable "cidr_ipv4" {
  description = "CIDR for IPV4"
  default = "10.0.0.0/16"
}
variable "public_subnet" {
  description = "Public Subnet CIDR"
  default = "10.0.0.0/24"
}
variable "private_subnet" {
  description = "Private Subnet CIDR"
  default = "10.0.1.0/24"
}
variable "ssh_key_name" {
  default     = ""
  description = "Amazon AWS Key Pair Name"
}
variable "private_key_pem_file" {
  description = "Private Key PEM File with file location"
  default = ""
}
variable "prefix" {
  description = "Prefix to be used in all resources for this project"
  default = "coder_on_aws"
}