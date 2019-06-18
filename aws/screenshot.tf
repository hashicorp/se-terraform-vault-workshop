resource "aws_virtual_instance" "web" {
  ami                    = "${var.ami}"
  vpc_security_group_ids = ["${var.security-groups}"]
  instance_type          = "${var.server-size}"
  key_name               = "${var.sshkey}"

  tags = {
    Name = "${var.hostname}"
  }
}
