variable "environment" {
  description = "Environment name (e.g., prod, dev, test)"
  type        = "string"
}

variable "name" {
  description = "Name for this bastion host service"
  type        = "string"
}

variable "bastion_allowed_admin_cidrs" {
  description = "CIDR blocks that can access this host"
  type        = "list"
}

variable "bastion_vpc_id" {
  description = "VPC that the bastion host and NLB will be created in"
  type        = "string"
}

variable "bastion_nlb_subnets" {
  description = "Subnets to create the NLB in (specify 3)"
  type        = "list"
}

variable "bastion_nlb_internal" {
  description = "Create the NLB on an internal (true) or internet-facing (false) scheme"
  type        = "string"
  default     = "true"
}

variable "bastion_host_ami" {
  description = "AMI to use for the bastion host instances"
  type        = "string"
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion"
  type        = "string"
  default     = "t2.micro"
}


variable "bastion_asg_min_size" {
  description = "Min Instances to create in ASG"
  type        = "string"
  default     = 1
}

variable "bastion_asg_max_size" {
  description = "Max Instances to create in ASG"
  type        = "string"
  default     = 1
}

variable "bastion_asg_subnets" {
  description = "Subnets to create instances in"
  type        = "list"
}

variable "bastion_keyname" {
  description = "Keypair to create instance with"
  type        = "string"

}
