
resource "aws_security_group" "sg_coder_on_aws_public_admin" {
  name        = "sg_coder_on_aws_public_admin"
  description = "Security Group for public Admin Server"
  vpc_id      = "${data.aws_vpc.vpc_coder_on_aws.id}"
  tags        = {    Name = "sg_coder_on_aws_public_admin"  }
  egress{
    description       = "All egress traffic"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }
  ingress{
    description       = "All Inbound SSH"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }
  ingress{
    description       = "All Inbound Ping"
    from_port         = 0
    to_port           = 0
    protocol          = "icmp"
    cidr_blocks       = ["0.0.0.0/0"]
  }
  /* Uncomment this to run Coder*/
  /*ingress{
    description       = "Coder UI 443"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }*/
  ingress{
    description       = "Coder UI 80"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }
  /* Uncomment this to run Teleport
  ingress{
    description       = "Teleport Web UI"
    from_port         = 3080
    to_port           = 3080
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }*/
}


resource "aws_instance" "i_public_admin" {
    ami               = "${var.ec2_ami}"
    instance_type     = "${var.type}"
    #HArdcoding Availability Zone to avoid t2.micro from getting created in 2d
    availability_zone = "us-west-2a"
    key_name          = "${var.ssh_key_name}"
    subnet_id         = "${aws_subnet.sn_public.id}"
    security_groups   = ["${aws_security_group.sg_coder_on_aws_public_admin.id}"]
    tags              = {    Name = "i_coder_on_aws_public_admin"  }

    # Copy jffree.pem file to admin server
    provisioner "file" {
      source      = "${var.private_key_pem_file}"
      destination = "jffree.pem"

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("${var.private_key_pem_file}")}"
      }
    }
    # Uncomment to install Coder
    provisioner "file" {
      source      = "files/"
      destination = "/home/ec2-user/"

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("${var.private_key_pem_file}")}"
      }
    }
    provisioner "remote-exec" {
      inline = [
          "sudo yum update -y",
          "sudo chmod 400 jffree.pem",

          /* Uncomment to Installing Docker */
          "sudo amazon-linux-extras install docker -y",
          "sudo service docker start",
          "sudo usermod -a -G docker ec2-user",          /**/
          
          /* Un-Comment these if you need to use Teleport
          "wget ${var.teleport_origin}${var.teleport_file}",
          "tar -xzf ${var.teleport_file}",
          "cd teleport",
          "sudo ./install",
          "cd examples/systemd",
          "sudo cp teleport.service /etc/systemd/system/teleport.service",
          "sudo systemctl daemon-reload",
          "sudo systemctl enable teleport",
          "sudo systemctl start teleport",
          "sleep 25",
          "systemctl status teleport -l",
          "cd ../..",
          "sudo ./tctl users add ec2-user",*/

          /* UnComment these to use Coder...  */
          "wget ${var.coder_url}${var.coder_filename}.tar.gz",
          "tar xvzf ${var.coder_filename}.tar.gz",
          "sudo mv coder.service /etc/systemd/system/coder.service",
          "sudo chmod +x /home/ec2-user/runcoder.sh",
          "sleep 4s",
          "sudo systemctl start coder",
          "sleep 4s",
          "sudo systemctl enable coder",
          /**/
        ]

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("${var.private_key_pem_file}")}"
      }
    }
}


output "coder_on_aws_public_admin_ssh" {
  value = "ssh -i \"${aws_instance.i_public_admin.key_name}.pem\" ec2-user@${aws_instance.i_public_admin.public_dns}"
}
output "coder_on_aws_public_admin_coder_ui" {
  value = "http://${aws_instance.i_public_admin.public_dns}"
}
/* Un-Comment these if you need to use Teleport
output "coder_on_aws_public_teleport" {
  value = "https://${aws_instance.i_public_admin.public_dns}:3080"
}*/