variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "mediawiki"
}
variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "10.0.0.0/16"
}
variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}
variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "ssh_key_private" {
  description = "Update your private key path in next line"
  type = string
  default = "~/Documents/personal/techofy.pem"
}

variable "ssh_public_key" {
  description = "Update your Public key path in next line"
  type = string
  default = "~/Documents/personal/techofy.pub"
}


