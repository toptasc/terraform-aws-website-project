terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.58.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}


resource "aws_security_group" "tf-sec-gr" {
  name = "tf-provisioner-sg-1"
  tags = {
    Name = "tf-provisioner-sg-1"
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      protocol = "tcp"
      to_port = 22
      cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
      from_port = 0
      protocol = -1
      to_port = 0
      cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_instance" "my_linux" {
  ami = "ami-005f9685cb30f234b"
  instance_type = "t2.micro"
  key_name = "cagriskey" # use your pem key without ".pem"
  security_groups = ["tf-provisioner-sg-1"]
  tags = {
    Name = "terraform-instance-with-provisioner"
  }
  user_data = <<EOF
		#! /bin/bash
            yum update -y
            yum install httpd -y
            FOLDER="https://raw.githubusercontent.com/toptasc/Kittens1-project/main/Project-101-kittens-carousel-static-website-ec2/static-web"
            cd /var/www/html
            wget $FOLDER/index.html
            wget $FOLDER/cat0.jpg
            wget $FOLDER/cat1.jpg
            wget $FOLDER/cat2.jpg
            wget $FOLDER/cat3.png
            systemctl start httpd
            systemctl enable httpd
	EOF
} 
output "tf_example_public_ip" {
  value = "http://${aws_instance.my_linux.public_ip}"

}