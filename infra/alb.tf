## subnet creation 

resource "aws_subnet" "public_subnets" {
    count             = length(var.public_subnet_cidrs)  # Number of subnets to create, based on the length of the CIDR list
    vpc_id            = aws_vpc.main.id                  # Associate each subnet with the main VPC
    cidr_block        = element(var.public_subnet_cidrs, count.index)  # Set the CIDR block for each subnet from the list
    availability_zone = element(var.azs, count.index)    # Set the availability zone for each subnet from the list
    tags = {
        Name = "Public Subnet ${count.index + 1}"          # Tag each subnet with a unique name
  }
}


// creating the vpc 
//https://spacelift.io/blog/terraform-aws-vpc
resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
 enable_dns_support   = true
 enable_dns_hostnames = true
 tags = {
    Name = "vpc"
 }
}
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}
//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
// gateway internet access so vpc can access
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}



# Security group for EC2s with app containers on them (App instances)
resource "aws_security_group" "ALBSecGroup" {
  vpc_id = aws_vpc.main.id
  name   = "ALBSecGroup"

  # Allow SSH access from your specific IP
  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Open to the world for HTTP access
  }

  # Allow HTTP access from anywhere
  ingress {
    from_port   = 0
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world for HTTP access
  }

  # Allow all outbound traffic
  # set to this because problems with pinging host 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world for HTTP access
  }

  tags = {
    Name = "ALBSecGroup"
  }
}



// security group for the PostgreSQL DB container instance
resource "aws_security_group" "DBSecGroup" {
  vpc_id = aws_vpc.main.id
  name   = "DBSecGroup"

  # might replace with actual CIDRs if needed
  ingress {
    from_port   = 0
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", "0.0.0.0/0"]  # The app instances' , subnets maybe later
  }

  # Allow all outbound traffic from the DB instance
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DBSecGroup"
  }
}

# instance 1 app config
resource "aws_instance" "instance_a" {
  ami                         = var.ami_id         # ref for the the passed ami_id variable in global
  instance_type               = var.instance_type  # ref for the instance_type variable  in global
  key_name                    = aws_key_pair.admin.key_name
  subnet_id                   = aws_subnet.public_subnets[0].id
  associate_public_ip_address = true
  security_groups      = [aws_security_group.ALBSecGroup.id]
  tags = {
    Name = "App1 instance (sectionB)"       # ref for the instance name
  }
}

# instance 2 app config
resource "aws_instance" "instance_b" {
  ami                         = var.ami_id         # ref for the the passed ami_id variable in global
  instance_type               = var.instance_type  # ref for the instance_type variable  in global
  key_name                    = aws_key_pair.admin.key_name
  subnet_id                   = aws_subnet.public_subnets[1].id
  associate_public_ip_address = true
  security_groups      = [aws_security_group.ALBSecGroup.id]
  tags = {
    Name = "App2 instance (sectionB)"       # ref for the instance name
  }
}

# instance 3 - database container
resource "aws_instance" "instance_c" {
  ami                         = var.ami_id         # ref for the the passed ami_id variable in global
  instance_type               = var.instance_type  # ref for the instance_type variable  in global
  key_name                    = aws_key_pair.admin.key_name
  subnet_id                   = aws_subnet.public_subnets[2].id
  associate_public_ip_address = true
  security_groups     = [aws_security_group.DBSecGroup.id]
  tags = {
    Name = "DB container instance (sectionB)"       # ref for the instance name
  }
}
# ------------------------------------------
# load Balancer config

resource "aws_lb" "LoadBalancer" {
  name               = "AppLoadBalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [
  aws_security_group.ALBSecGroup.id,
  aws_security_group.DBSecGroup.id,
  aws_security_group.vms.id
  ]
  subnets            = aws_subnet.public_subnets[*].id

  tags = {
    Name = "The Load Balancer"
  }
}
## routing table needed for gateway 
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}



