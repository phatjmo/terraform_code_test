

variable "public_key_path" {
  description = "The local public key path. Default: ~/.ssh/id_rsa.pub"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "availability_zone" {
  description = "Availability zone to deploy this instance into"
  type        = string
  default     = null
}

variable "instance_name" {
  description = "Value for the Name tag on the created EC2 instance. If none provided, will default to random pet name"
  type        = string
  default = null
}

variable "instance_type" {
  description = "Specify the class and size of the instance, defaults to t2.micro"
  type        = string
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "Specify the VPC that this instance should be deployed to"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Specify the Subnet ID to deploy this instance into"
  type        = string
  default     = null
}

variable "bucket_name" {
  description = "Specify a unique bucket name for this EC2 instance to access, if none provided, will default to random pet name"
  type        = string
  default = null
}

variable "ami" {
  description = "Specify the AMI you wish to load, default is Amazon Linux 2"
  type        = string
  default     = null
}

variable "environment" {
  description = "The environment this instance will be deployed into"
  type        = string
  default     = "Dev"
}

variable "make_public" {
    description = "Should this instance be publically accessible?"
    type = bool
    default = true
}