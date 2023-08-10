data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Training linkeding blog VPC"
  }
}

resource "aws_subnet" "blog_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "tf-blog-subnet"
  }
}

resource "aws_network_interface" "blog_netinterface" {
  subnet_id   = aws_subnet.blog_subnet.id
  private_ips = ["10.0.1.1"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  network_interface {
    network_interface_id = aws_network_interface.blog_netinterface.id
    device_index         = 0
  }

  vpc_security_group_ids = [aws_security_group.blog.id]

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_security_group" "blog" {
  name        = "blog"
  description = "Allow http and https in. Allow everything out"

  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "blog_http_in" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_https_in" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_everything_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}
