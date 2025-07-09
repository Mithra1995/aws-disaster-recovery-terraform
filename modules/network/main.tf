resource "aws_vpc" "project_VPC" {
  cidr_block = var.vpc_cidr
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
   tags = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_subnet" "pubsub" {
  count                   = length(var.pubsub)
  vpc_id                  = aws_vpc.project_VPC.id
  cidr_block              = var.pubsub[count.index]
  availability_zone       = var.pubsub_az[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-pubsub-${count.index}"
  }
}

resource "aws_subnet" "prisub" {
  count                   = length(var.prisub)
  vpc_id                  = aws_vpc.project_VPC.id
  cidr_block              = var.prisub[count.index]
  availability_zone       = var.prisub_az[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-prisub-${count.index}"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.project_VPC.id
  tags   = { Name = "${var.name_prefix}-public-rt" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.pubsub)
  subnet_id      = aws_subnet.pubsub[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count = var.create_nat ? 1 : 0
  lifecycle { prevent_destroy = false }
}

resource "aws_nat_gateway" "nat" {
  count         = var.create_nat ? 1 : 0
  subnet_id     = aws_subnet.pubsub[0].id
  allocation_id = var.nat_eip_id != "" ? var.nat_eip_id : aws_eip.nat[0].id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.project_VPC.id
  tags   = { Name = "${var.name_prefix}-private-rt" }

  dynamic "route" {
    for_each = var.create_nat ? [1] : [] 
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat[0].id
    }
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.prisub)
  subnet_id      = aws_subnet.prisub[count.index].id
  route_table_id = aws_route_table.private.id
}
resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.project_VPC.id
  tags   = { Name = "${var.name_prefix}-igw" }
}