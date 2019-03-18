resource "aws_security_group" "sg_coder_on_aws_public_nat" {
  name        = "sg_coder_on_aws_public_nat"
  description = "Security Group for public NAT Server"
  vpc_id      = "${data.aws_vpc.coder_on_aws_vpc.id}"
  tags        = {    Name = "sg_coder_on_aws_public_nat"  }
  egress{
    description       = "All egress traffic"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }
  egress{
    description       = "Outbound Ping"
    from_port         = 0
    to_port           = 0
    protocol          = "icmp"
    cidr_blocks       = ["0.0.0.0/0"]
  }
  
  ingress{
    description       = "Inbound SSH from Admin server Only"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["${aws_instance.i_public_admin.private_ip}/32"]
  }
  ingress{
    description       = "Inbound HTTP from Private Subnet Only"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["${var.private_subnet}"]
  }
  ingress{
    description       = "Inbound HTTPS from Private Subnet Only"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["${var.private_subnet}"]
  }
  ingress{
    description       = "Inbound Ping from Private and Public Subnets Only"
    from_port         = 0
    to_port           = 0
    protocol          = "icmp"
    cidr_blocks       = ["${var.private_subnet}","${var.public_subnet}"]
  }
}
resource "aws_instance" "i_public_nat" {
    #depends_on                   = ["${aws_instance.i_public_admin}"]
    ami                           = "${var.nat_ami}"
    instance_type                 = "${var.type}"
    #HArdcoding Availability Zone to avoid t2.micro from getting created in 2d
    availability_zone             = "us-west-2a"
    key_name                      = "${var.ssh_key_name}"
    subnet_id                     = "${aws_subnet.sn_public.id}"
    security_groups               = ["${aws_security_group.sg_coder_on_aws_public_nat.id}"]
    associate_public_ip_address   = "true"
    source_dest_check             = "false"
    tags                          = {    Name = "i_coder_on_aws_public_nat"  }

    provisioner "remote-exec" {
      inline = [
          "sudo yum update -y",
        ]

      connection {
        type                    = "ssh"
        bastion_host            = "${aws_instance.i_public_admin.public_dns}"
        host                    = "${aws_instance.i_public_nat.private_ip}"
        bastion_private_key     = "${file("${var.private_key_pem_file}")}"
        user                    = "ec2-user"
        private_key             = "${file("${var.private_key_pem_file}")}"
      }
    }
}


output "coder_on_aws_public_nat" {
  value = "ssh -i \"${aws_instance.i_public_nat.key_name}.pem\" ec2-user@${aws_instance.i_public_nat.private_dns}"
}