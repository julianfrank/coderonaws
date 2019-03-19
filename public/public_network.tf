//Public Subnet
resource "aws_subnet" "sn_public" {
  vpc_id                  = "${data.aws_vpc.vpc_coder_on_aws.id}"
  cidr_block              = "${var.public_subnet}"
  #HArdcoding Availability Zone to avoid t2.micro from getting created in 2d
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = "true"
  tags                    = {    Name = "sn_coder_on_aws_public"  }
}
resource "aws_route_table" "rt_coder_on_aws_public" {
  vpc_id  = "${data.aws_vpc.vpc_coder_on_aws.id}"
  tags    = {Name = "rt_coder_on_aws_public"}
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig_coder_on_aws.id}"
  }
}

resource "aws_route_table_association" "rta_coder_on_aws_public" {
  subnet_id      = "${aws_subnet.sn_public.id}"
  route_table_id = "${aws_route_table.rt_coder_on_aws_public.id}"
}
resource "aws_internet_gateway" "ig_coder_on_aws" {
  vpc_id  = "${data.aws_vpc.vpc_coder_on_aws.id}"
  tags    = {Name="ig_coder_on_aws"}
}