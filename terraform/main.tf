terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend "s3" {
    bucket         = "hussbot-tf"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "hussbot-tf-locks"
    encrypt        = true
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_instance" "bot_server" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "ssh-key"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.main.id]
  tags = {
    Name = "HussbotServer"
  }
  
}

resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 22
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 22
  }
  ]
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = var.public_key
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "hussbot-tf"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.db_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"  
  
  attribute {
    name = "LockID"
    type = "S"
  }
}

output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.bot_server.public_ip
}