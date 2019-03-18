
resource "aws_security_group" "sg_coder_on_aws_private" {
  name        = "sg_coder_on_aws_private"
  description = "Security Group for private Subnet"
  vpc_id      = "${data.aws_vpc.vpc_coder_on_aws.id}"
  tags        = {    Name = "sg_coder_on_aws_private"  }

  egress{
    description       = "HTTP"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }
  egress{
    description       = "HTTPS"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress{
    description       = "SSH Rule"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["${data.aws_instance.i_coder_on_aws_public_admin.private_ip}/32"]
  }
  ingress{
    description       = "Ping Rule"
    from_port         = 0
    to_port           = 0
    protocol          = "icmp"
    cidr_blocks       = ["${var.private_subnet}","${data.aws_instance.i_coder_on_aws_public_admin.private_ip}/32"]
  }
}
resource "aws_instance" "i_private" {
    //depends_on                    = ["${aws_route_table.rt_coder_on_aws_private}"]
    ami                           = "${var.ec2_ami}"
    instance_type                 = "${var.type}"
    #HArdcoding Availability Zone to avoid t2.micro from getting created in 2d
    availability_zone             = "us-west-2a"
    key_name                      = "${var.ssh_key_name}"
    associate_public_ip_address   = "true"
    subnet_id                     = "${aws_subnet.sn_private.id}"
    security_groups               = ["${aws_security_group.sg_coder_on_aws_private.id}"]
    tags                          = {    Name = "i_coder_on_aws_private"  }

    provisioner "remote-exec" {
      inline = [
        #"echo going to sleep for 6 seconds ... Hopefully NAT Instance is ready by then",
        #"sleep 6",
        "sudo yum update -y"
        ]

      connection {
        bastion_host  = "${data.aws_instance.i_coder_on_aws_public_admin.public_ip}"
        host          = "${aws_instance.i_private.private_ip}"
        type          = "ssh"
        user          = "ec2-user"
        private_key   = "${file("${var.private_key_pem_file}")}"
      }
    }
    provisioner "local-exec" {
      command = "echo {public_ssh: ssh -i \"${aws_instance.i_private.key_name}.pem\" ec2-user@${aws_instance.i_private.private_ip}} >> private.log"
    }
}
output "coder_on_aws_private" {
  value = "ssh -i \"${aws_instance.i_private.key_name}.pem\" ec2-user@${aws_instance.i_private.private_ip}"
}