# Create a new Custom VPC with cidr 
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "main_vpc" }
}

# Creates an internet gateway attached to the main VPC ID. Would be attached to public subnet
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = { Name = "vpc_igw" }
}

# Create 2 Public and 2 Private Subnets and attach to the main VPC ID created 

# Create 2 public subnets
resource "aws_subnet" "public_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "Public Subnet ${count.index + 1}" }
}

# Create 2 private subnets
resource "aws_subnet" "private_subnets" {
  count             = 2
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = { Name = "Private Subnet ${count.index + 1}" }
}

# Creates an EIP(Elastic IP) for the NAT gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# Create NAT gateway and assign the EIP to it. The NAT gateway is attached to the private subnet 
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  depends_on    = [aws_internet_gateway.eks_igw]
  tags = { Name = "Natty GW" }
}

# Create a route table for the public subnet assigned to VPC id
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = { Name = "Public Subnet Route Table" }
}
# Create a route to the Internet/NAT gateway for the public subnet
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_igw.id
}

# Associate the 2 public subnet with the public subnet route table
resource "aws_route_table_association" "public_rta" {
  count          = 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Create a route table for the private subnet assigned to VPC id 
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = { Name = "Private Subnet Route Table" }
}

# Create a route to the NAT gateway for the private subnet
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

# Associate the 2 private subnet with the private subnet route table
resource "aws_route_table_association" "private_rta" {
  count          = 2
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
