
provider "aws" {

  region  = "ap-south-1"
  profile = "colearn"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = "weby-vpc"
  cidr = "172.10.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["172.10.1.0/24"]
  private_subnets = ["172.10.2.0/24", "172.10.3.0/24"]

  # Enable DNS
  # Any instance that is assigned a public IPV4 address
  # will also receive a public DNS hostname.
  # ref: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html#vpc-dns-hostnames
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Custom DHCP
  # for custom domain name, DNS servers, NTP servers,
  # netbios servers and/or netbios server type
  enable_dhcp_options  = true

  dhcp_options_domain_name = "ap-south-1.compute.internal"

  # We want one NAT gateway per AZ. These NAT gateways will be
  # deployed in the respective public subnets of the AZs.

  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  # VPC endpoints for S3 (app logs), and Dynamodb
  # - removes need for IGW, NAT, VPN, or AWS Direct Connect connection
  # - ref: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-endpoints.html
  # - setting these flags also creates the required route table associations
  enable_s3_endpoint       = false
  enable_dynamodb_endpoint = false

  # Common tags for all resources created with this module

  
}

