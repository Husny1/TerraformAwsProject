// basic config vars for provider and Section A instance
variable "aws_profile" {
  description = "The AWS CLI profile to use."
  type        = string
  default     = "default"
}


variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-0866a3c8686eaeeba"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance (section A)"
  type        = string
  default     = "AlpineInstance"
}

// ip config  vars 
variable "path_to_ssh_public_key" {
  description = "Path to the SSH public key"
  type        = string
  default     = "~/.ssh/admin.pub"  # Use the standard .ssh path
}

variable "path_to_ssh_private_key" {
  description = "Path to the SSH public key"
  type        = string
  default     = "~/.ssh/admin.pem"  
}


variable "my_ip_address" {
  description = "The IP address of the user accessing the instance"
  type        = string
  default     = "202.63.78.225"
}

variable "allow_all_ip_addresses_to_access_database_server" {
  description = "Boolean flag to allow all IP addresses access to the database server"
  type        = bool
  default     = true
}

//load balanacer vars
variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.7.0/24"]

}

variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24", "10.0.8.0/24"]
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}