variable "az1" {
  description = "The Availability zone"
  default     = "ap-south-1a"
}

variable "alb_name_prefix" {
  description = "Prefix for the ALB and security group names."
  default     = ""
}

variable "alb_subnets" {
  description = "List of subnet IDs where the ALB will be deployed."
  type        = list(string)
  default     = ["subnet-xxxxx", "subnet-xxxxx", "subnet-xxxxx"]
}

variable "vpc_id" {
  description = "The ID of the VPC where the resources will be created."
  default     = "vpc-xxxxx" # Replace with your VPC ID
}

variable "ami_name" {
  description = "AMI name"
  type        = string
  default     = "xxxxx AMI"
}

variable "instance_id" {
  description = "Source (staging) instance ID whose AMI will create"
  type        = string
  default     = "i-xxxxx"
}

variable "instance_type" {
  description = "Size of EC2 Instances"
  type        = string
  default     = ""
}

variable "instance_keypair" {
  description = "Key pair for alb machines"
  type        = string
  default     = ""
}

variable "iam_role_arn" {
  description = "ARN of the IAM role to be associated with instances"
  type        = string
  default     = "arn:aws:iam::xxxxx:instance-profile/<Profile-ARN>"  # Replace with your IAM role ARN
}

variable "acm_certificate_arn" {
  description = "The ACM certificate ARN to be used for the ALB HTTPS listener"
  default     = "arn:aws:acm:ap-south-1:xxxxx:certificate/xxxxx-xxxxx-xxxxx-xxxxx-xxxxx"
}
