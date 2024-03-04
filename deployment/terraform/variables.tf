variable "aws_region" {
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
  default     = "ami-0a23a9827c6dab833"
}
