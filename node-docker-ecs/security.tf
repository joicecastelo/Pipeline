
#grupo de segrança para ALB

resource "aws_security_group" "lb_security" {
  name        = "alb_security"
  description = "controls acess to the ALB"
  vpc_id      = aws_vpc.project_ecs.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "ALB security Group"
  }
}



# Grupo de seguranca ECS

resource "aws_security_group" "ecs_security" {
  name = "ecs-tasks-security"
  #description = "allow inbound acess from Athe LB only"
  vpc_id = aws_vpc.project_ecs.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_security.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }


  tags = {
    Name = "ECS security Group"
  }
}



/*

#grupo de segurança para ECS dummy API 

resource "aws_security_group" "dummy_api_sg" {
  name        = "dummy-api-sg"
  description = "permite trajeto de HTTP para porta  8000"
  vpc_id      = aws_vpc.project_ecs.id

  ingress {
    description     = "http"
    from_port       = 8000
    to_port         = 8000
    self            = "false"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.lb_security.id]



  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}




#Criar Security Group privado
resource "aws_security_group" "private_vms_sg" {
  name        = "${var.environment}-private-vms-sg"
  description = "allow  SSH traffic and ICMPs to private"
  vpc_id      = aws_vpc.project_ecs.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = var.public_cidr_a

  }


  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    #cidr_blocks = var.public_cidr_a

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }


  tags = {
    Name = "private security Group"
  }
}



#criar security group public

resource "aws_security_group" "public_vms_sg" {
  name        = "${var.environment}-public-vms-sg"
  description = "allow  SSH traffic and ICMPs to private"
  vpc_id      = aws_vpc.project_ecs.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }


  tags = {
    Name = "Public security Group"
  }
}



# Criar instancia  EC2 privada
resource "aws_instance" "private_vm" {
  ami                         = "ami-007855ac798b5175e" # AMI = Ubuntu 22.04 AMD64
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_east_a.id
  associate_public_ip_address = false

  root_block_device {
    volume_size           = "10"
    volume_type           = "standard"
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    aws_security_group.private_vms_sg.id,
    aws_security_group.dummy_api_sg.id
  ]

}


# Criar instancia  EC2 privada
resource "aws_instance" "public_vm" {
  ami                         = "ami-007855ac798b5175e" # AMI = Ubuntu 22.04 AMD64
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_east_a.id 

  root_block_device {
    volume_size           = "10"
    volume_type           = "standard"
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    aws_security_group.public_vms_sg.id,
    aws_security_group.dummy_api_sg.id
  ]

}

*/