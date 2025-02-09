variable "vpc_id" {
  description = "vpcid"
  type        = string
}

variable "example_id" {
  description = "ec2webserverid"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet ID for the EC2 instance"
  type        = list(string)
}

variable "security_group_id" {
  description = "The security group ID for the EC2 instance"
  type        = string
}