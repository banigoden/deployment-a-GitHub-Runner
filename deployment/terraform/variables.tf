variable "aws_region" {
  type        = string
  description = "Default AWS Region"
  default     = "eu-central-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "192.168.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "192.168.2.0/24"
}


variable "ami_number" {
  description = "AMI number"
  type        = string
  default     = "ami-0f7204385566b32d0"
}

variable "instance_name" {
  type    = string
  default = "django"
}

variable "size" {
  type    = string
  default = "t2.micro"
}


variable GIT_TOKEN {
  type        = string
  default     = "xxxxxxx"
  description = "description"
}

