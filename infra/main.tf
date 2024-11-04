terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
      
    }
  }
  ## created my own s3 backend using my bucketname and  own credentials in the cli to make user ENV
    ## MUST CREATE A USER WITH CLI OR IN YOUR CREDENTIALS OR MAKE A IAMI USER
    # https://developer.hashicorp.com/terraform/language/backend/s3
    # used this bucket for my own AWS acc # change accordingly to  foostatebucket1 with specs to assignment 
  backend "s3" {
    bucket         = "foostatebuckets3660418"  
    region         = "us-east-1"
    profile        = "user1"
    dynamodb_table = "foostatelock"  # DynamoDB table for state locking
    key            = "terraform.tfstate"  # State file key in the S3 bucket
  }
}


provider "aws" {
  region     = var.aws_region # have to use provided acc region, cant change
}


data "aws_vpc" "default" {
  default = true
}




data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_key_pair" "admin" {
  key_name   = "admin"  
  public_key = file(var.path_to_ssh_public_key)
  
}



locals {
  vms = {
    app = {},
    db  = {}
  }
  # This next line is a bit complicated... if you allow all IP addresses, then
  # the CIDR is "0.0.0.0/0" (everybody), if not then it's your IP address
  # with a "/32" suffix which means just one IP address. 
  # See https://cidr.xyz/ to learn more about the CIDR notation for IP addresses.
  allowed_cidrs_for_db = var.allow_all_ip_addresses_to_access_database_server ? ["0.0.0.0/0"] : ["${var.my_ip_address}/32"]
}

resource "aws_instance" "servers" {
  ami = var.ami_id         # ref for the the passed ami_id variable in global
  instance_type = var.instance_type  # ref for the instance_type variable  in global
  key_name = aws_key_pair.admin.key_name
  subnet_id                   = aws_subnet.public_subnets[3].id
  associate_public_ip_address = true
  security_groups      = [aws_security_group.vms.id]
  

  user_data = <<-EOF
    #!/bin/bash
    echo "Installing Ansible"
    sudo apt-get update -y
    sudo apt-get install -y ansible-core
  EOF
  
  tags = {
    Name = var.instance_name        # ref for the instance name
  }
 
}

resource "aws_security_group" "vms" {
  vpc_id = aws_vpc.main.id
  name = "vms"
  

  # SSH
  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP in
  ingress {
    from_port   = 0
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # PostgreSQL in
  ingress {
    from_port   = 0
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = local.allowed_cidrs_for_db
  }

  # HTTPS out
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
  }
