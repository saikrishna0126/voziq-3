variable "region" {
  description = "The AWS region to deploy resources"
  default     = "us-west-2" # Change to your preferred region
}

variable "aws_vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidr" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "http_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS port"
  type        = number
  default     = 443
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 22
}
variable "key_name" {
  description = "The name of the key pair"
  type        = string
  default     = "test"  # You can change this default value
}

variable "private_key_filename" {
  description = "The filename to save the private key"
  type        = string
  default     = "test-key"  # You can change this default value
}

variable "rsa_bits" {
  description = "The number of bits for the RSA key"
  type        = number
  default     = 4096  # You can change this value if needed
}

variable "ami_id_linux" {
  description = "AMI ID for the Linux ubuntu(22.04) instance"
  type        = string
  default     = "ami-05134c8ef96964280" # Replace with your preferred Amazon Linux AMI ID
}

variable "ami_id_windows" {
  description = "AMI ID for the Windows instance"
  type        = string
  default     = "ami-0845068028e672a07" # Replace with your preferred Windows AMI ID
}

variable "instance_types" {
  description = "Instance types for the EC2 instances"
  type        = list(string)
  default     = ["t2.micro", "t2.micro", "t2.micro", "t2.micro", "t2.micro"] # Four Linux and one Windows
}
