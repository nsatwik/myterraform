provider "aws" {
  region = "ap-south-1"
}

##VPC
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraform_vpc"
  }
}

##Subnets
##ap-south-1a
resource "aws_subnet" "my_subnet_1a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform_subnet_1a"
  }
}

##ap-south-1b
resource "aws_subnet" "my_subnet_1b" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform_subnet_1b"
  }
}
##ap-south-1c
resource "aws_subnet" "my_subnet_1c" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform_subnet_1c"
  }
}
##Internet Gateways
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "terraform_igw"
  }
}

##Route Tables
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "terraform_rt"
  }
}

##Route Table Associaations
resource "aws_route_table_association" "my_rt_accociation_1a" {
  subnet_id      = aws_subnet.my_subnet_1a.id
  route_table_id = aws_route_table.my_rt.id
}

resource "aws_route_table_association" "my_rt_accociation_1b" {
  subnet_id      = aws_subnet.my_subnet_1b.id
  route_table_id = aws_route_table.my_rt.id
}

resource "aws_route_table_association" "my_rt_accociation_1c" {
  subnet_id      = aws_subnet.my_subnet_1c.id
  route_table_id = aws_route_table.my_rt.id
}

##Security Groups
resource "aws_security_group" "my_sg" {
  name        = "terraform_sg"
  description = "Terraform security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##Create ec2 instance
resource "aws_instance" "my_instance" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.my_subnet_1a.id
  security_groups = [aws_security_group.my_sg.id]

  tags = {
    Name = "terraform_instance"
  }
  ##User data to install nginx
  user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install nginx -y
  sudo rm -rf /var/www/html/*
  git clone https://github.com/nsatwik/browny-nginx.git /home/ubuntu/browny-nginx
  sudo cp -r /home/ubuntu/browny-nginx/* /var/www/html/
  sudo service nginx restart
  sudo apt install fontconfig openjdk-21-jre -y
  sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
  echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
  sudo apt update
  sudo apt install jenkins -y
  sudo apt install maven -y
  sudo apt install docker.io -y
  sudo apt install unzip -y
  curl -fsSL https://awscli.amazonaws.com/v2/install.sh | sudo bash -s -- --system
  wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.61/bin/apache-tomcat-10.1.61.tar.gz /home/ubuntu/apache-tomcat-10.1.61.tar.gz
  sudo tar -xvzf /home/ubuntu/apache-tomcat-10.1.61.tar.gz -C /opt/
  sudo mv /opt/apache-tomcat-10.1.61 /opt/tomcat
  sudo chmod +x /opt/tomcat/bin/*.sh
  sudo sh /opt/tomcat/bin/startup.sh
  EOF
}