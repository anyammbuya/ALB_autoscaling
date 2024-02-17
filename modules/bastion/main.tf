data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "bastion_host" {
 
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  subnet_id              = var.subnet_id_public
  associate_public_ip_address = true
  vpc_security_group_ids = var.security_group_id_bastion

  key_name = var.key_name

 
}