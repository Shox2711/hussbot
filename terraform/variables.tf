variable "region" { 
    default = "eu-west-1"
}

variable "ami" {
    default = "ami-09ac4fc4f947dfc5d"
}

variable "instance_type" {
    default = "t4g.micro"
}

variable "public_key" {
    type = string
}

variable "bucket_name" {
    default = "hussbot-tf"
}

variable "acl_value" {
    default = "private"
}

variable "db_name" {
    default = "hussbot-tf-locks"
}
