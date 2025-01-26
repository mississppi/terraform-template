# ----------------------
# VPC Configuration
# ----------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# ----------------------
# Subnet Configuration
# ----------------------
# 既存のパブリックサブネット (ap-northeast-1a)
resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1a"
  }
}

# 既存のプライベートサブネット (ap-northeast-1a)
resource "aws_subnet" "private_subnet_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "private-subnet-1a"
  }
}

# 新しいパブリックサブネット (ap-northeast-1c)
resource "aws_subnet" "public_subnet_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"  # 新しいCIDRブロック
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1c"
  }
}

# 新しいプライベートサブネット (ap-northeast-1c)
resource "aws_subnet" "private_subnet_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"  # 新しいCIDRブロック
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "private-subnet-1c"
  }
}

# ----------------------
# Route Table Configuration
# ----------------------

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

# ----------------------
# IGW Configuration
# ----------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# ----------------------
# Route for Public Subnet via Internet Gateway
# ----------------------

resource "aws_route" "public_to_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# ----------------------
# NAT Gateway Configuration
# ----------------------

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1c.id
  tags = {
    Name = "nat-gateway"
  }
}

# ----------------------
# Route for Private Subnet via NAT Gateway
# ----------------------

resource "aws_route" "private_to_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Public Subnet Association
resource "aws_route_table_association" "public_subnet_association_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_association_1c" {
  subnet_id      = aws_subnet.public_subnet_1c.id
  route_table_id = aws_route_table.public.id
}

# Private Subnet Association
resource "aws_route_table_association" "private_subnet_association_1a" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet_association_1c" {
  subnet_id      = aws_subnet.private_subnet_1c.id
  route_table_id = aws_route_table.private.id
}

# ----------------------
# Security Group Configuration
# ----------------------

# Public Security Group (for instances in the public subnet)
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public-sg"
  }

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # 開発用。必要に応じて制限
  }

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# Private Security Group (for instances in the private subnet)
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private-sg"
  }

  ingress {
    description      = "Allow traffic from public subnet"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups  = [aws_security_group.public_sg.id]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# ----------------------
# RDS Security Group Configuration
# ----------------------

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rds-sg"
  }

  # Allow MySQL connections from private_sg
  ingress {
    description      = "Allow MySQL access from private subnet instances"
    from_port        = 3306 # MySQLポート
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.private_sg.id] # private_sgからのアクセスを許可
  }

  # Allow all outbound traffic (required for RDS to function correctly)
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}