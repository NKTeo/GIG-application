# VPC 
resource "aws_vpc" "application_vpc" {
    cidr_block = "10.0.0.0/16"
	tags = {
        Name = "${var.environment}-vpc"
    }
}

# IGW
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.application_vpc.id
    tags = {
        Name = "${var.environment}-igw"
    }
}

# NAT Gateway
resource "aws_nat_gateway" "gw" {
    allocation_id = aws_eip.nat_gw_eip.id
    subnet_id     = aws_subnet.public_subnet_a.id
    tags = {
        Name = "${var.environment}-nat-gw"
    }
}

# EIP for NAT Gateway
resource "aws_eip" "nat_gw_eip" {
    vpc = true
}

# Public Subnets
resource "aws_subnet" "public_subnet_a" {
    vpc_id     = aws_vpc.application_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-southeast-1a"
    tags = {
        Name = "${var.environment}-public-subnet-a"
    }
}

resource "aws_subnet" "public_subnet_b" {
    vpc_id     = aws_vpc.application_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-southeast-1b"
    tags = {
        Name = "${var.environment}-public-subnet-b"
    }
}

# Private Subnets
resource "aws_subnet" "private_subnet_a" {
    vpc_id     = aws_vpc.application_vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "ap-southeast-1a"
    tags = {
        Name = "${var.environment}-private-subnet-a"
    }
}

resource "aws_subnet" "private_subnet_b" {
    vpc_id     = aws_vpc.application_vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "ap-southeast-1b"
    tags = {
        Name = "${var.environment}-private-subnet-b"
    }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.application_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "govtech-public-igw-rt"
    }
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.application_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.gw.id
    }

    tags = {
        Name = "govtech-private-nat-rt"
    }
}

# Route Table Associations
resource "aws_main_route_table_association" "promote_public_rt_main" {
    vpc_id         = aws_vpc.application_vpc.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_a_rt" {
    subnet_id = aws_subnet.public_subnet_a.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_b_rt" {
    subnet_id = aws_subnet.public_subnet_b.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_a_rt" {
    subnet_id = aws_subnet.private_subnet_a.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_b_rt" {
    subnet_id = aws_subnet.private_subnet_b.id
    route_table_id = aws_route_table.private_route_table.id
}