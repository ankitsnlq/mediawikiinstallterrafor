provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway = false
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
    Environment = "mediawiki"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file(var.ssh_public_key)}"
}

resource "aws_security_group" "web" {
  name = "web"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port = 22 
    to_port  = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port  = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = "0"
    to_port  = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_security_group" "db" {
  name = "db"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port = 3306
    to_port  = 3306
    protocol = "TCP"
    security_groups = ["${aws_security_group.web.id}"]
  }
  egress {
    from_port = "0"
    to_port  = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]
  subnet_id = "${element(module.vpc.public_subnets, 3)}"
  key_name = "${aws_key_pair.deployer.id}"

  provisioner "remote-exec" {
    inline = ["sudo apt update"]

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.ssh_key_private)}"
    }
  }

  provisioner "local-exec" {
    command = "export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key ${var.ssh_key_private} playbook.yml" 
  }
  
  tags = {
    Name = "webserver"
    ENV = "http"
  }  
}

resource "aws_instance" "db" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  subnet_id = "${element(module.vpc.private_subnets, 3)}"
  key_name = "${aws_key_pair.deployer.id}"
  user_data = "${file("install_mysql.sh")}"
  
  tags = {
    Name = "dbserver"
    ENV = "mysql"
  }  
}

output "publicip_webserver" {
  description = "Public IP of Webserver"
  value       = "${aws_instance.web.public_ip}"
}

output "DBSERVER_IP" {
  description = "Private IP of Database server."
  value       = "${aws_instance.db.private_ip}"
}