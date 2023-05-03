
#-------Create VPC 

resource "aws_vpc" "project_ecs" {
  cidr_block = var.cidr

  tags = {
    Name = "My VPC"
  }
}

#--------Create Private subnets for ECS

resource "aws_subnet" "private_east_a" {
  vpc_id            = aws_vpc.project_ecs.id
  cidr_block        = var.private_cidr_a
  availability_zone = var.region_a

  tags = {
    Name = "Private East A"
  }
}

resource "aws_subnet" "private_east_b" {
  vpc_id            = aws_vpc.project_ecs.id
  cidr_block        = var.private_cidr_b
  availability_zone = var.region_b


  tags = {
    Name = "Private East B"
  }
}


#--------Create Public subnets 

resource "aws_subnet" "public_east_a" {
  vpc_id            = aws_vpc.project_ecs.id
  cidr_block        = var.public_cidr_a
  availability_zone = var.region_a

  tags = {
    Name = "Public East A"
  }
}

resource "aws_subnet" "public_east_b" {
  vpc_id            = aws_vpc.project_ecs.id
  cidr_block        = var.public_cidr_b
  availability_zone = var.region_b


  tags = {
    Name = "Public East B"
  }
}


# Criar elastic ip

resource "aws_eip" "nat" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

}

#Criando internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project_ecs.id

  tags = {
    Name = "Internet gw"
  }
}



#Criando NAT gateway

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_east_a.id

  tags = {
    Name = "gw NAT"
  }

}



#Criando route table

# Route table publica a
resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.project_ecs.id
  tags = {
    Name = " route table public 1"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }
}

# Associacão do route publico a
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_east_a.id
  route_table_id = aws_route_table.public_a.id
}


# Route table privado a 
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.project_ecs.id
  tags = {
    Name = " route table privada 1"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id

  }
}

# Associação route table private a
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_east_a.id
  route_table_id = aws_route_table.private_a.id
}


#Route table publico b 
resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.project_ecs.id
  tags = {
    Name = " route table public 2"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }
}

# Associação route table publico b
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_east_b.id
  route_table_id = aws_route_table.public_b.id
}


# Route table privado b
resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.project_ecs.id
  tags = {
    Name = "route table priva 2"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id

  }
}

# Associação route table private b
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_east_b.id
  route_table_id = aws_route_table.private_b.id
}




# Criar Load balancer

resource "aws_alb" "alb" {
  name = "dummy-api-ecs-alb"
  #internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_security.id]
  subnets            = [aws_subnet.public_east_a.id, aws_subnet.public_east_b.id]

}
/*listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

    instances = [aws_instance.private_vm.id]
    
  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }
  

}

*/






# Criar target grupo

resource "aws_lb_target_group" "mydummy_api_tg" {
  name        = "mydummy-api-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.project_ecs.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    matcher             = "200"
    path                = var.health_check_path
    interval            = 30

  }
}





#Create and ALB Listener that points to the Target Group just created

resource "aws_lb_listener" "dummy_api_listener" {
  load_balancer_arn = aws_alb.alb.arn

  port     = "80"
  protocol = "HTTP"
  default_action {

    type             = "forward"
    target_group_arn = aws_lb_target_group.mydummy_api_tg.arn
  }


  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }

}



/*
# Criar auto escala 


resource "aws_appautoscaling_target" "ecs_fagate" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/serviceName"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

}

resource "aws_appautoscaling_policy" "ecs_policy_up" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_fagate.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_fagate.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_fagate.service_namespace


  step_scaling_policy_configuration {
    adjustment_type         = "changeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximun"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}





# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-1c"
}

*/