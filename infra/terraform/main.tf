# EVERYTHING WITHIN THIS SCRIPT WILL BE CREATED IN  THE REGION US-EAST1

############# CREATION OF THE VPC AND SUBNETS #############

#CREATING THE MAIN VPC
resource "aws_vpc" "SNB3-VPC-TERRAFORM" {
  cidr_block = "11.0.0.0/16"
  tags = {
    Name = "SNB3-Testing"
  }
}



#FIRST PUBLIC SUBNET FOR FRONTEND INSTANCES
resource "aws_subnet" "SNB3-public-Subnet-Virginia" {
  vpc_id            = aws_vpc.SNB3-VPC-TERRAFORM.id
  cidr_block        = "11.0.0.0/20"
  availability_zone = "us-east-1a"  # Change to your preferred AZ

  tags = {
    Name = "SNB3-public-Subnet-Virginia"
  }
}

resource "aws_subnet" "SNB3-public-Subnet-Virginia-1b" {
  vpc_id            = aws_vpc.SNB3-VPC-TERRAFORM.id
  cidr_block        = "11.0.16.0/20"
  availability_zone = "us-east-1b"  # Change to your preferred AZ

  tags = {
    Name = "SNB3-public-Subnet-Virginia-1b"
  }
}


# PRIVATE SUBNET TO BE CREATED FOR INSTANCES THAT CANNOT BE PUBLICLY ACCESSIBLE
resource "aws_subnet" "SNB3-Private-subnet-Virginia" {
  vpc_id            = aws_vpc.SNB3-VPC-TERRAFORM.id
  cidr_block        = "11.0.32.0/20"
  availability_zone = "us-east-1a"  # Change to your preferred AZ

  tags = {
    Name = "SNB3-Private-subnet-Virginia"
  }
}

resource "aws_subnet" "SNB3-Private-subnet-Virginia-1b" {
  vpc_id            = aws_vpc.SNB3-VPC-TERRAFORM.id
  cidr_block        = "11.0.48.0/20"
  availability_zone = "us-east-1b"  # Change to your preferred AZ

  tags = {
    Name = "SNB3-Private-subnet-Virginia-1b"
  }
}


############ CREATING THE SUBNETS USED BY THE DATABASE ############

# RDS REQUIRES AT LEAST 2 SUBNETS IN ORDER FOR IT TO BE CREATED
# THEREFORE WE CREATE AT LEAST 2 OR MORE AND ATTACH THEM TO A SUBNET GROUP
resource "aws_subnet" "SNB3-RDS-subnet1-Virginia" {
  vpc_id            = aws_vpc.SNB3-VPC-TERRAFORM.id
  cidr_block        = "11.0.64.0/24"
  availability_zone = "us-east-1a"  # Change to your preferred AZ

  tags = {
    Name = "SNB3-RDS-subnet1-Virginia"
  }
}

resource "aws_subnet" "SNB3-RDS-subnet2-Virginia" {
  vpc_id            = aws_vpc.SNB3-VPC-TERRAFORM.id
  cidr_block        = "11.0.80.0/24"
  availability_zone = "us-east-1b"  # Change to your preferred AZ

  tags = {
    Name = "SNB3-RDS-subnet2-Virginia"
  }
}

# THE SUBNET THAT WILL BE USED FOR NAT GATEWAY
resource "aws_subnet" "SNB3-NAT-public-Subnet-Virginia" {
  vpc_id            = aws_vpc.SNB3-VPC-TERRAFORM.id
  cidr_block        = "11.0.96.0/24"
  availability_zone = "us-east-1d"  # Change to your preferred AZ

  tags = {
    Name = "SNB3-NAT-public-Subnet-Virginia"
  }
}

# DEFINING THE SUBNET GROUP AND ATTACHING THE RELEVAN SUBNETS
resource "aws_db_subnet_group" "SNB3-SUBNET-GROUP" {
  name       = "snb-subnet-group"
  subnet_ids = [
    aws_subnet.SNB3-RDS-subnet1-Virginia.id,
    aws_subnet.SNB3-RDS-subnet2-Virginia.id,
  ]

  tags = {
    Name = "snb-subnet-group"
  }
}

# INTERNET GATEWAY CREATION
resource "aws_internet_gateway" "SNB3-IGW" {
  vpc_id = aws_vpc.SNB3-VPC-TERRAFORM.id

  tags = {
    Name = "SNB3-Internet-Gateway"
  }
}

###### CREATING THE ROUTE TABLES ######

###### CREATING THE PUBLIC RT ######
resource "aws_route_table" "SNB3-public-RT" {
  vpc_id = aws_vpc.SNB3-VPC-TERRAFORM.id

  tags = {
    Name = "SNB3-Public-RouteTable"
  }
}

###### CREATING THE RDS RT ######
resource "aws_route_table" "SNB3-RDS-route" {
  vpc_id = aws_vpc.SNB3-VPC-TERRAFORM.id

  tags = {
    Name = "SNB3-RDS-route"
  }
}


###### CREATING THE PRIVATE RDS ######
resource "aws_route_table" "SNB3-Private-RT" {
  vpc_id = aws_vpc.SNB3-VPC-TERRAFORM.id

  tags = {
    Name = "SNB3-Private-RouteTable"
  }
}


######## ATTACHING ROUTES TO THE ROUTE TABLES ########

# NOTE: THE COMMENTED PARTS ARE FOR FUTURE USE CASES, CAN BE IGNORED

# adding the internet gateway route to the SNB3-public-RT
resource "aws_route" "SNB3-public-route" {
  route_table_id         = aws_route_table.SNB3-public-RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.SNB3-IGW.id
}


# resource "aws_route" "SNB3-public-local-route" {
#   route_table_id         = aws_route_table.SNB3-public-RT.id
#   destination_cidr_block = "10.0.0.0/16"
#   local_gateway_id = "local"
# }

# adding the internet gateway route to the SNB3-private-subnet
resource "aws_route" "SNB3-private-nat-route" {
  route_table_id         = aws_route_table.SNB3-Private-RT.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.SNB3-NAT-Gateway.id
}

# # adding the internet gateway route to the SNB3-private-subnet
# resource "aws_route" "SNB3-private-local-route" {
#   route_table_id         = aws_route_table.SNB3-Private-RT.id
#   destination_cidr_block = "10.0.0.0/16"
#   local_gateway_id = "local"
# }
#
# # adding the proper routes to the rds
#
# resource "aws_route" "SNB3-RDS-local-route" {
#   route_table_id         = aws_route_table.SNB3-RDS-route.id
#   destination_cidr_block = "10.0.0.0/16"
#   local_gateway_id = local
# }


######### ATTACHING THE SUBNETS TO THEIR RESPECTIVE ROUTE TABLES #########


# ASSOCIATE PUBLIC SUBNET TO PUBLIC RT (Virginia)

resource "aws_route_table_association" "SNB3-Public-RT-assoc-virginia" {
  subnet_id      = aws_subnet.SNB3-public-Subnet-Virginia.id
  route_table_id = aws_route_table.SNB3-public-RT.id
}

# ASSOCIATE PUBLIC SUBNET 1b TO PUBLIC RT (Virginia)

resource "aws_route_table_association" "SNB3-Public-RT-assoc-virginia-1b" {
  subnet_id      = aws_subnet.SNB3-public-Subnet-Virginia-1b.id
  route_table_id = aws_route_table.SNB3-public-RT.id
}

# ASSOCIATE NAT SUBNET TO PUBLIC RT (Virginia)
resource "aws_route_table_association" "SNB3-NAT-RT-assoc-virginia" {
  subnet_id      = aws_subnet.SNB3-NAT-public-Subnet-Virginia.id
  route_table_id = aws_route_table.SNB3-public-RT.id
}

# ASSOCIATE PRIVATE SUBNET TO PRIVATE RT (Virginia)
resource "aws_route_table_association" "SNB3-Private-RT-assoc-virginia" {
  subnet_id      = aws_subnet.SNB3-Private-subnet-Virginia.id
  route_table_id = aws_route_table.SNB3-Private-RT.id
}

# ASSOCIATE PRIVATE SUBNET 1b TO PRIVATE RT (Virginia)
resource "aws_route_table_association" "SNB3-Private-RT-assoc-virginia-1b" {
  subnet_id      = aws_subnet.SNB3-Private-subnet-Virginia-1b.id
  route_table_id = aws_route_table.SNB3-Private-RT.id
}

# ASSOCIATE RDS SUBNET1 TO RDS RT (Virginia)
resource "aws_route_table_association" "SNB3-Private-RDS1-assoc-virginia" {
  subnet_id      = aws_subnet.SNB3-RDS-subnet1-Virginia.id
  route_table_id = aws_route_table.SNB3-RDS-route.id
}

# ASSOCIATE RDS SUBNET2 TO RDS RT  (Virginia)
resource "aws_route_table_association" "SNB3-Private-RDS2-assoc-virginia" {
  subnet_id      = aws_subnet.SNB3-RDS-subnet2-Virginia.id
  route_table_id = aws_route_table.SNB3-RDS-route.id
}


######## CREATING THE ELASTIC IP'S THAT WILL BE USED ########

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "SNB3-NAT-EIP" {
  tags = {
    Name = "SNB3-NAT-EIP"
  }
}

# Create the NAT Gateway in a public subnet
resource "aws_nat_gateway" "SNB3-NAT-Gateway" {
  allocation_id = aws_eip.SNB3-NAT-EIP.id
  subnet_id     = aws_subnet.SNB3-NAT-public-Subnet-Virginia.id

  tags = {
    Name = "SNB3-NAT-Gateway"
  }

  depends_on = [aws_internet_gateway.SNB3-IGW]  # Ensures IGW is created first
}

############# END OF THE VPC AND SUBNETS #############


#############CREATION OF THE SECURITY GROUPS #############

#############CREATION OF THE FRONTEND SECURITY GROUP #############
resource "aws_security_group" "SNB3-FRONTEND"{
  vpc_id = aws_vpc.SNB3-VPC-TERRAFORM.id

  ## HTTP ##
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # IMPORVEMENT COULD BE TO ADD THE ACTUAL ADDRESS OF THE BASTION HOSTS IP
  # REMEMBER TO ADD A DEPENDS ON CLAUSE FIRST AND ATTACH THE SECURITY GROUP AFTER THE BASTIONS CREATION
  # THIS APPLIES TO EVERY SECURITY GROUP THAT HAS A SSH INBOUND RULE

  ## SSH ##
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"] #change to bastion private ip
  }

  ## HTTPS ##
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ## ICMP ##
  ingress {
    from_port = "-1"
    to_port = "-1"
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ## OUTBOUND ##
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SNB3-FRONTEND-TERRAFORM"
  }
}


#############CREATION OF THE BACKEND SECURITY GROUP #############

resource "aws_security_group" "SNB3-BACKEND"{
  vpc_id = aws_vpc.SNB3-VPC-TERRAFORM.id

  ## SSH ##
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #change to bastion private ip
  }


  ## PORT 3000 ##
  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ## ICMP ##
  ingress {
    from_port = "-1"
    to_port = "-1"
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ## OUTBOUND ##
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SNB3-BACKEND"
  }
}

#############CREATION OF THE BASTION SECURITY GROUP #############

resource "aws_security_group" "SNB3-BASTION"{
  vpc_id = aws_vpc.SNB3-VPC-TERRAFORM.id

  ## SSH ##
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #change to bastion private ip
  }

  ## ICMP ##
  ingress {
    from_port = "-1"
    to_port = "-1"
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ## OUTBOUND ##
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SNB3-BASTION-TERRAFORM"
  }
}


############# CREATION OF THE RDS SECURITY GROUP #############


resource "aws_security_group" "SNB3-EC2-ONLY" {
  vpc_id = aws_vpc.SNB3-VPC-TERRAFORM.id

  tags = {
    Name = "EC2-RDS-1-TERRAFORM"
  }
}

resource "aws_security_group" "SNB3-RDS-ONLY" {
  vpc_id = aws_vpc.SNB3-VPC-TERRAFORM.id

  tags = {
    Name = "RDS-EC2-1-TERRAFORM"
  }
}

resource "aws_security_group_rule" "SNB3-RDS-OUTBOUND" {
  from_port         = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.SNB3-RDS-ONLY.id
  to_port           = 3306
  type              = "ingress"
  source_security_group_id = aws_security_group.SNB3-EC2-ONLY.id
}

resource "aws_security_group_rule" "SNB3-EC2-OUTBOUND" {
  from_port         = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.SNB3-EC2-ONLY.id
  to_port           = 3306
  type              = "egress"
  source_security_group_id = aws_security_group.SNB3-RDS-ONLY.id
}

############# END OF THE SECURITY GROUPS #############

###### CREATING THE BASTION EC2 ######

resource "aws_instance" "SNB3-BASTION" {
  ami                    = "ami-071226ecf16aa7d96"  # AMAZON LINUX
  instance_type          = "t2.micro"      # Choose an instance type
  key_name               = "bastion-snb3" # Replace with your actual key pair name
  subnet_id              = aws_subnet.SNB3-public-Subnet-Virginia.id
  vpc_security_group_ids = [aws_security_group.SNB3-BASTION.id]



  tags = {
    Name = "SNB3-BASTION-TERRAFORM"
  }
}

# Associate the EIP with the Bastion instance
resource "aws_eip_association" "SNB3_BASTION_EIP" {
  instance_id   = aws_instance.SNB3-BASTION.id
  allocation_id = "eipalloc-0223ef72e2677a472"
}


######## END OF CREATION FOR THE EC2's ########

######## CREATING A RDS MYSQL DATABASE ########

data "aws_secretsmanager_secret_version" "rds_creds"{
  secret_id = "terraformCollect"
}

locals {
  rds_secret= jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string)
  rds_username_safe = lookup(local.rds_secret, "username", null)
  rds_password_safe = lookup(local.rds_secret, "password", null)
}

resource "aws_rds_cluster" "SNB3-aurora-cluster" {
  cluster_identifier      = "snb3-aurora-cluster"
  engine                 = "aurora-mysql"
  engine_version         = "8.0.mysql_aurora.3.04.0"  # Adjust to a valid version
  database_name          = "SNB3-AURORA"
  master_username        = local.rds_username_safe
  master_password        = local.rds_password_safe
  db_subnet_group_name   = aws_db_subnet_group.SNB3-SUBNET-GROUP.name
  vpc_security_group_ids = [aws_security_group.SNB3-RDS-ONLY.id]
  skip_final_snapshot    = true
}

# Writer Instance (Primary DB)
resource "aws_rds_cluster_instance" "SNB3-aurora-writer" {
  identifier         = "snb3-aurora-writer"
  cluster_identifier = aws_rds_cluster.SNB3-aurora-cluster.id
  instance_class     = "db.r6g.large"  # Choose an appropriate instance type
  engine            = "aurora-mysql"
}

# Read Replica (Optional, for scaling reads)
resource "aws_rds_cluster_instance" "SNB3-aurora-reader" {
  identifier         = "snb3-aurora-reader"
  cluster_identifier =  aws_rds_cluster.SNB3-aurora-cluster.id
  instance_class     = "db.r6g.large"
  engine            = "aurora-mysql"
  publicly_accessible = false
}


########## CREATING OUR API GATEWAY ###########

resource "aws_api_gateway_rest_api" "my_api" {
  name        = "SNB3-TERRAFORM-API"
  description = "API for carousel, todo and location operations"
}

########## RESOURCES ##########

# CREATING HEALTH RESOURCE
resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "health"
}

# CREATING THE CARROUSEL RESOURCE
resource "aws_api_gateway_resource" "carrousel" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "carrousel"
}

# CREATING THE TODO RESOURCE
resource "aws_api_gateway_resource" "todo" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "todo"
}

# CREATING THE TODO_ID RESOURCE
resource "aws_api_gateway_resource" "todo_id" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_resource.todo.id
  path_part   = "{id}"
}

# CREATING THE LOCATIONS RESOURCE

resource "aws_api_gateway_resource" "locations" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "locations"
}

# CREATING THE LOCATIONS ID RESOURCE

resource "aws_api_gateway_resource" "locations_id" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_resource.locations.id
  path_part   = "{id}"
}

########## END OF RESOURCES ##########

########## CREATING THE METHODS FOR OUR RESOURCES ##########

# CREATING THE GET METHOD FOR HEALTH
resource "aws_api_gateway_method" "get_health" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

# CREATING THE GET METHOD FOR CARROUSEL
resource "aws_api_gateway_method" "get_carrousel" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.carrousel.id
  http_method   = "GET"
  authorization = "NONE"
}

# CREATING THE POST METHOD FOR LOCATIONS

resource "aws_api_gateway_method" "post_locations" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.locations.id
  http_method = "POST"
  authorization = "NONE"
}

# CREATING THE DELETE METHOD FOR /locations/{id}

resource "aws_api_gateway_method" "delete_locations" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.locations_id.id
  http_method = "DELETE"
  authorization = "NONE"
}


# CREATING THE GET METHOD FOR /locations/{id}

resource "aws_api_gateway_method" "get_locations" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.locations_id.id
  http_method = "GET"
  authorization = "NONE"
}


# CREATING THE PUT METHOD FOR /locations/{id}

resource "aws_api_gateway_method" "put_locations" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.locations_id.id
  http_method = "PUT"
  authorization = "NONE"
}


# CREATING GET METHOD FOR TODO
resource "aws_api_gateway_method" "get_todo" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.todo.id
  http_method   = "GET"
  authorization = "NONE"
}

# CREATING POST METHOD FOR TODO
resource "aws_api_gateway_method" "post_todo" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.todo.id
  http_method   = "POST"
  authorization = "NONE"
}

# CREATING PUT METHOD FOR TODO_ID
resource "aws_api_gateway_method" "put_todo_id" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.todo_id.id
  http_method   = "PUT"
  authorization = "NONE"
}

# CREATING DELETE METHOD FOR TODO_ID
resource "aws_api_gateway_method" "delete_todo_id" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.todo_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

########## END OF METHODS ##########

########## CREATING INTEGRATIONS ##########

# CREATING INTEGRATION REQUEST FOR GET HEALTH
resource "aws_api_gateway_integration" "get_health" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.health.id
  http_method             = aws_api_gateway_method.get_health.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${aws_lb.SNB3_ALB_BACKEND_TERRAFORM.dns_name}/health"
}

# CREATING INTERGRATION REQUESTS FOR POST locations

resource "aws_api_gateway_integration" "post_locations" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.locations.id
  http_method             = aws_api_gateway_method.post_locations.http_method
  integration_http_method = "POST"
  type                    = "HTTP"
  uri                     = "http://${aws_lb.SNB3_ALB_BACKEND_TERRAFORM.dns_name}/locations"
}

# CREATING INTERGRATION REQUESTS FOR GET locations/{id}

resource "aws_api_gateway_integration" "get_locations" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.locations_id.id
  http_method             = aws_api_gateway_method.get_locations.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${aws_lb.SNB3_ALB_BACKEND_TERRAFORM.dns_name}/locations/{id}"
}

# CREATING INTERGRATION REQUESTS FOR PUT locations/{id}

resource "aws_api_gateway_integration" "put_locations" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.locations_id.id
  http_method             = aws_api_gateway_method.put_locations.http_method
  integration_http_method = "PUT"
  type                    = "HTTP"
  uri                     = "http://${aws_lb.SNB3_ALB_BACKEND_TERRAFORM.dns_name}/locations/{id}"
}

# CREATING INTERGRATION REQUESTS FOR PUT locations/{id}

resource "aws_api_gateway_integration" "delete_locations" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.locations_id.id
  http_method             = aws_api_gateway_method.delete_locations.http_method
  integration_http_method = "DELETE"
  type                    = "HTTP"
  uri                     = "http://${aws_lb.SNB3_ALB_BACKEND_TERRAFORM.dns_name}/locations/{id}"
}

# CREATING INTEGRATION REQUEST FOR GET TODO

resource "aws_api_gateway_integration" "get_todo" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.todo.id
  http_method             = aws_api_gateway_method.get_todo.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${aws_lb.SNB3_ALB_BACKEND_TERRAFORM.dns_name}/todo"
}

# CREATING INTEGRATION REQUEST FOR POST TODO

resource "aws_api_gateway_integration" "post_todo" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.todo.id
  http_method             = aws_api_gateway_method.post_todo.http_method
  integration_http_method = "POST"
  type                    = "HTTP"
  uri                     = "http://${aws_lb.SNB3_ALB_BACKEND_TERRAFORM.dns_name}/todo"
}

# CREATING INTEGRATION REQUEST FOR GET CARROUSEL

resource "aws_api_gateway_integration" "get_carrousel" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.carrousel.id
  http_method             = aws_api_gateway_method.get_carrousel.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${aws_lb.SNB3_ALB_BACKEND_TERRAFORM.dns_name}/carrousel"
}

# CREATING INTEGRATION REQUEST FOR PUT TODO_ID

resource "aws_api_gateway_integration" "put_todo_id" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.todo_id.id
  http_method             = aws_api_gateway_method.put_todo_id.http_method
  integration_http_method = "PUT"
  type                    = "HTTP"
  uri                     = "http://${aws_lb.SNB3_ALB_BACKEND_TERRAFORM.dns_name}/todo/{id}"
}

# CREATING INTEGRATION REQUEST FOR DELETE TODO_ID

resource "aws_api_gateway_integration" "delete_todo_id" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.todo_id.id
  http_method             = aws_api_gateway_method.delete_todo_id.http_method
  integration_http_method = "DELETE"
  type                    = "HTTP"
  uri                     = "http://${aws_lb.SNB3_ALB_BACKEND_TERRAFORM.dns_name}/todo/{id}"
}

################## END OF INTEGRATIONS ##################

################## CORS OPTIONS for /HEALTH ##################
resource "aws_api_gateway_method" "options_health" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_health" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.options_health.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

resource "aws_api_gateway_method_response" "options_health_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.options_health.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_health_methods" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.options_health.http_method
  status_code = aws_api_gateway_method_response.options_health_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET, OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }

  response_templates = {
    "application/json" = ""
  }
}

################## CORS OPTIONS for /locations/{id} ##################

resource "aws_api_gateway_method" "options_locations_id" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.locations_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_locations_id" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.locations_id.id
  http_method = aws_api_gateway_method.options_locations_id.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

resource "aws_api_gateway_method_response" "options_locations_id_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.locations_id.id
  http_method = aws_api_gateway_method.options_locations_id.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_locations_methods" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.locations_id.id
  http_method = aws_api_gateway_method.options_locations_id.http_method
  status_code = aws_api_gateway_method_response.options_locations_id_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET, OPTIONS, POST, DELETE, PUT'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }

  response_templates = {
    "application/json" = ""
  }
}

################## CORS OPTIONS for /locations ##################

resource "aws_api_gateway_method" "options_locations_methods" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.locations.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_locations" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.locations.id
  http_method = aws_api_gateway_method.options_locations_methods.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

resource "aws_api_gateway_method_response" "options_locations_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.locations.id
  http_method = aws_api_gateway_method.options_locations_methods.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_locations_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.locations.id
  http_method = aws_api_gateway_method.options_locations_methods.http_method
  status_code = aws_api_gateway_method_response.options_locations_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST, OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }

  response_templates = {
    "application/json" = ""
  }
}



################## CORS OPTIONS for /CARROUSEL ##################
resource "aws_api_gateway_method" "options_carrousel" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.carrousel.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_carrousel" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.carrousel.id
  http_method = aws_api_gateway_method.options_carrousel.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

resource "aws_api_gateway_method_response" "options_carrousel" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.carrousel.id
  http_method = aws_api_gateway_method.options_carrousel.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_carrousel" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.carrousel.id
  http_method = aws_api_gateway_method.options_carrousel.http_method
  status_code = aws_api_gateway_method_response.options_carrousel.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET, OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }

  response_templates = {
    "application/json" = ""
  }
}

################## CORS OPTIONS for /TODO ##################
resource "aws_api_gateway_method" "options_todo" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.todo.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_todo" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.todo.id
  http_method = aws_api_gateway_method.options_todo.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

resource "aws_api_gateway_method_response" "options_todo" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.todo.id
  http_method = aws_api_gateway_method.options_todo.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_todo" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.todo.id
  http_method = aws_api_gateway_method.options_todo.http_method
  status_code = aws_api_gateway_method_response.options_todo.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET, POST, OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }

  response_templates = {
    "application/json" = ""
  }
}


######### CORS FOR TODO/ID #############

resource "aws_api_gateway_method" "options_todo_id" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.todo_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_todo_id" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.todo_id.id
  http_method = aws_api_gateway_method.options_todo_id.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

resource "aws_api_gateway_method_response" "options_todo_id" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.todo_id.id
  http_method = aws_api_gateway_method.options_todo_id.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_todo_id" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.todo_id.id
  http_method = aws_api_gateway_method.options_todo_id.http_method
  status_code = aws_api_gateway_method_response.options_todo_id.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'PUT, DELETE, OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }

  response_templates = {
    "application/json" = ""
  }
}

################## END CORS OPTIONS ##################


########## DEPLOYING THE API ##########

resource "aws_api_gateway_deployment" "my_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id

  stage_name  = "snb3-terraform-deploy"
  depends_on  = [
    aws_api_gateway_method.get_health,
    aws_api_gateway_method.get_carrousel,
    aws_api_gateway_method.get_todo,
    aws_api_gateway_method.post_todo,
    aws_api_gateway_method.put_todo_id,
    aws_api_gateway_method.delete_todo_id,
    aws_api_gateway_integration.get_health,
    aws_api_gateway_integration.get_carrousel,
    aws_api_gateway_integration.get_todo,
    aws_api_gateway_integration.post_todo,
    aws_api_gateway_integration.put_todo_id,
    aws_api_gateway_integration.delete_todo_id,
    aws_api_gateway_integration.get_locations,
    aws_api_gateway_integration.post_locations,
    aws_api_gateway_integration.put_locations,
    aws_api_gateway_integration.delete_locations
  ]
}

######## CREATING A S3 BUCKET FOR IMAGES AND OTHER FILES ########

# Create S3 bucket
resource "aws_s3_bucket" "SNB3-BUCKET-TERRAFORM" {
  bucket = "snb3-staticassets-terraform" # Change to a unique bucket name
  force_destroy = true # when a destroy command is executed it will empty the s3 bucket and then delete it

  tags = {
    Name = "SNB3-STATICASSETStest"
  }
}

resource "aws_s3_bucket_cors_configuration" "SNB3-BUCKET-CORS-TERRAFORM" {
  bucket = aws_s3_bucket.SNB3-BUCKET-TERRAFORM.bucket
  cors_rule {
    allowed_headers = ["*"]  # Allows any headers
    allowed_methods = ["GET", "POST", "PUT"]  # Allows GET, POST, and PUT methods
    allowed_origins = ["*"]  # Allows any origin, change this to specific origins for security
    expose_headers  = []    # Exposes no headers to the browser (optional)
  }
}

# Disable "Block Public Access" settings
resource "aws_s3_bucket_public_access_block" "SNB3-PUBLIC-ACCESS" {
  bucket                  = aws_s3_bucket.SNB3-BUCKET-TERRAFORM.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# # Add a bucket policy to allow public access
resource "aws_s3_bucket_policy" "SNB3-BUCKET-PUBLIC-READ" {
  bucket = aws_s3_bucket.SNB3-BUCKET-TERRAFORM.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.SNB3-BUCKET-TERRAFORM.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket.SNB3-BUCKET-TERRAFORM]
}

data "template_file" "env_json" {
  template = file("user_data/terra_test.config.json.tmpl")
  vars = {
    api_url = "${aws_api_gateway_deployment.my_api_deployment.invoke_url}"
  }
}

resource "aws_s3_object" "env_config_json" {
  bucket       = aws_s3_bucket.SNB3-BUCKET-TERRAFORM.bucket
  key          = "static_assets/config.json"
  content      = data.template_file.env_json.rendered
  content_type = "application/json"
}

# Use local-exec provisioner to upload all files in the folder
resource "null_resource" "upload_folder" {
  provisioner "local-exec" {
    command = "aws s3 cp Static_assets/ s3://${aws_s3_bucket.SNB3-BUCKET-TERRAFORM.bucket}/static_assets/ --recursive"
  }

  depends_on = [
    aws_s3_bucket.SNB3-BUCKET-TERRAFORM,
    aws_rds_cluster.SNB3-aurora-cluster,]  # Ensure bucket is created before upload
}


######## CREATION OF AMI's for autoscaling ########



########### CREATING OUR TEMPLATE FOR FRONTEND AND BACKEND ###########


########### CREATING OUR TEMPLATE FOR FRONTEND  ###########

resource "aws_launch_template" "SNB3-LAUNCHTEMP-FRONTEND" {
  name = "SNB3-FRONTEND-TEMPLATE"
  image_id = "ami-0f52d58d9c3547f1c"
  instance_type = "t2.small"
  key_name = "snb3-frontend"
  user_data = base64encode(file("./user_data/frontend.sh"))

  lifecycle {
    create_before_destroy = true
  }

  network_interfaces {
    associate_public_ip_address = false
    subnet_id = aws_subnet.SNB3-public-Subnet-Virginia.id
    security_groups = [aws_security_group.SNB3-FRONTEND.id]
  }

  depends_on = [aws_security_group.SNB3-FRONTEND]
}


########### CREATING OUR TEMPLATE FOR BACKEND ###########

resource "aws_launch_template" "SNB3-LAUNCHTEMP-BACKEND" {
  name = "SNB3-BACKEND-TEMPLATE"
  image_id = "ami-0f52d58d9c3547f1c"
  instance_type = "t2.small"
  key_name = "snb3-backend"
  user_data = base64encode(file("./user_data/backend.sh"))

  lifecycle {
    create_before_destroy = true
  }

  network_interfaces {
    associate_public_ip_address = false
    subnet_id = aws_subnet.SNB3-Private-subnet-Virginia.id
    security_groups = [aws_security_group.SNB3-BACKEND.id, aws_security_group.SNB3-EC2-ONLY.id]
  }

  depends_on = [aws_security_group.SNB3-BACKEND]

}


########### CREATING OUR TARGET GROUP FOR THE BACKEND ###########
resource "aws_lb_target_group" "SNB3_BACKEND_TERRAFORM" {
  name        = "SNB3-BACKEND-TARGETS-TERRAFORM"
  target_type = "instance"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.SNB3-VPC-TERRAFORM.id # Ensure you reference the correct VPC

  # Define the health check
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  # Specify HTTP/1 protocol version
  protocol_version = "HTTP1"
}


########### CREATING OUR TARGET GROUP FOR THE FRONTEND ###########
resource "aws_lb_target_group" "SNB3_ALB_FRONTEND_TERRAFORM" {
  name        = "SNB3-FRONTEND-TARGETS-TERRAFORM"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.SNB3-VPC-TERRAFORM.id # Ensure you reference the correct VPC

  # Define the health check
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  # Specify HTTP/1 protocol version
  protocol_version = "HTTP1"
}


########### CREATING OUR BACKEND ALB ###########

resource "aws_lb" "SNB3_ALB_BACKEND_TERRAFORM" {

  name               = "SNB3-ALB-BACKEND"
  internal           = false  # Public-facing ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SNB3_ALB_SG.id]
  subnets           = [aws_subnet.SNB3-Private-subnet-Virginia.id, aws_subnet.SNB3-public-Subnet-Virginia.id] # Replace with actual subnet IDs
  ip_address_type    = "ipv4"
  enable_deletion_protection = false

}

# Security Group for ALB (Allows HTTP traffic on port 3000)
resource "aws_security_group" "SNB3_ALB_SG" {
  name        = "SNB3-ALB-SG"
  description = "Allow HTTP traffic on port 3000"
  vpc_id      = aws_vpc.SNB3-VPC-TERRAFORM.id # Ensure this is the correct VPC reference

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the internet (Adjust if needed)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the internet (Adjust if needed)
  }

  ingress {
    from_port = "-1"
    to_port = "-1"
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SNB3-ALB-SG"
  }
}

# HTTP Listener on Port 3000
resource "aws_lb_listener" "SNB3_HTTP_LISTENER_BACKEND" {
  load_balancer_arn = aws_lb.SNB3_ALB_BACKEND_TERRAFORM.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.SNB3_BACKEND_TERRAFORM.arn
  }
}

########### CREATING OUR FRONTEND ALB ###########

resource "aws_lb" "SNB3_ALB_FRONTEND" {
  name               = "SNB3-ALB-FRONTEND"
  internal           = false  # Public-facing ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SNB3_ALB_SG.id]
  subnets           = [aws_subnet.SNB3-Private-subnet-Virginia.id, aws_subnet.SNB3-public-Subnet-Virginia.id] # Replace with actual subnet IDs
  ip_address_type    = "ipv4"

  enable_deletion_protection = false
}

# HTTP Listener on Port 80
resource "aws_lb_listener" "SNB3_HTTP_LISTENER_FRONTEND" {
  load_balancer_arn = aws_lb.SNB3_ALB_FRONTEND.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.SNB3_ALB_FRONTEND_TERRAFORM.arn
  }
}


########### CREATING AUTOSCALING ###########

########### CREATING AUTOSCALING FRONTEND ###########

resource "aws_autoscaling_group" "SNB3-FRONTEND-SCALEGROUP" {
  name = "MY-FRONTEND-ASG-TERRAFORM"

  launch_template {
    id = aws_launch_template.SNB3-LAUNCHTEMP-FRONTEND.id
    version = "$Latest"
  }

  vpc_zone_identifier = [aws_subnet.SNB3-public-Subnet-Virginia.id, aws_subnet.SNB3-Private-subnet-Virginia.id]
  health_check_type = "EC2"
  health_check_grace_period = 300
  target_group_arns = [aws_lb_target_group.SNB3_ALB_FRONTEND_TERRAFORM.arn]
  desired_capacity = 1
  max_size = 8
  min_size = 1

  tag {

    key                 = "Name"
    propagate_at_launch = true
    value               = "Frontend-ASG"

  }

  depends_on = [aws_launch_template.SNB3-LAUNCHTEMP-FRONTEND]
}

resource "aws_autoscaling_policy" "SNB3-FRONTEND-POLICY-SCALING" {

  autoscaling_group_name = aws_autoscaling_group.SNB3-FRONTEND-SCALEGROUP.name
  name                   = "FRONTEND-CPU-SCALING"
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 65

  }

  estimated_instance_warmup = 300

}


########### CREATING AUTOSCALING BACKEND ###########

resource "aws_autoscaling_group" "SNB3-BACKEND-SCALEGROUP" {
  name = "MY-BACKEND-ASG-TERRAFORM"

  launch_template {
    id = aws_launch_template.SNB3-LAUNCHTEMP-BACKEND.id
    version = "$Latest"
  }

  vpc_zone_identifier = [aws_subnet.SNB3-public-Subnet-Virginia.id, aws_subnet.SNB3-Private-subnet-Virginia.id]
  health_check_type = "EC2"
  health_check_grace_period = 300
  target_group_arns = [aws_lb_target_group.SNB3_BACKEND_TERRAFORM.arn]
  desired_capacity = 1
  max_size = 8
  min_size = 1

  tag {

    key                 = "Name"
    propagate_at_launch = true
    value               = "Backend-ASG"

  }

  depends_on = [aws_launch_template.SNB3-LAUNCHTEMP-BACKEND]
}

resource "aws_autoscaling_policy" "SNB3-BACKEND-POLICY-SCALING" {

  autoscaling_group_name = aws_autoscaling_group.SNB3-BACKEND-SCALEGROUP.name
  name                   = "BACKEND-CPU-SCALING"
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 65

  }

  estimated_instance_warmup = 300

}

