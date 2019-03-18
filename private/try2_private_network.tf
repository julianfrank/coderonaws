//Private Subnet
resource "aws_route_table" "rt_coder_on_aws_private" {
  vpc_id  = "${data.aws_vpc.coder_on_aws_vpc.id}"
  tags    = {Name = "rt_coder_on_aws_private"}
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${data.aws_instance.i_coder_on_aws_public_nat.id}"
  }
}
resource "aws_subnet" "sn_private" {
  vpc_id                  = "${data.aws_vpc.vpc_coder_on_aws.id}"
  cidr_block              = "${var.private_subnet}"
  #HArdcoding Availability Zone to avoid t2.micro from getting created in 2d
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = "false"
  tags                    = {    Name = "sn_coder_on_aws_private"  }
}
resource "aws_route_table_association" "rta_coder_on_aws_private" {
  subnet_id      = "${aws_subnet.sn_private.id}"
  route_table_id = "${aws_route_table.rt_coder_on_aws_private.id}"
}
