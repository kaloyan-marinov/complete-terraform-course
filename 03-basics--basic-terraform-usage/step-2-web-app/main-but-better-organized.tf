terraform {
  backend "s3" {
    bucket         = "s3-bucket-terraform-state-for-my-web-app"
    key            = "03-basics--basic-terraform-usage/step-2-web-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-table-terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}



# The `data` block is used to reference an existing resource within AWS.
# (An alternative would be to configure a new VPC for this example.)
data "aws_vpc" "default_vpc" {
  default = true
}

# The `data` block is used to reference an existing resource within AWS.
data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
}



resource "aws_lb" "load_balancer" {
  name               = "web-app-lb"
  load_balancer_type = "application"
  # Configure which subnet to provision into.
  subnets = data.aws_subnet_ids.default_subnet.ids
  # Configure which security group to use.
  security_groups = [aws_security_group.alb.id]
}

resource "aws_instance" "instance_1" {
  ami             = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instances.name]
  user_data       = <<-EOF
              #!/bin/bash
              echo "'Hello world' from Instance 1" > index.html
              python3 -m http.server 8080 &
              EOF
}

resource "aws_instance" "instance_2" {
  ami             = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instances.name]
  user_data       = <<-EOF
              #!/bin/bash
              echo "'Hello world' from Instance 2" > index.html
              python3 -m http.server 8080 &
              EOF
}

# The following resource will be created solely for the sake of demonstration,
# meaning that it will not be used for anything.
resource "aws_s3_bucket" "bucket" {
  bucket        = "s3-bucket-step-2-web-app"
  force_destroy = true
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# The following resource will be created solely for the sake of demonstration,
# meaning that it will not be used for anything.
# (
# Later on in this tutorial,
# we will transition away from hardcoding credentials (as done below)
# to operating with credentials in a secure manner.
# )
resource "aws_db_instance" "db_instance" {
  allocated_storage = 20
  storage_type      = "standard"
  engine            = "postgres"
  engine_version    = "12"
  instance_class    = "db.t2.micro"
  # Using "postres-database" in the next line failed with
  # "Error creating DB Instance: InvalidParameterName: DBName must
  # begin with a letter and contain only alphanumeric characters"
  name = "postres_database"
  # Using "postres_username" in the next line failed with
  # "Error creating DB Instance: InvalidParameterValue: Invalid master user name"
  username            = "postres_username"
  password            = "postres-password"
  skip_final_snapshot = true
}



# The following resource is needed
# in order to enable inbound traffic to and outbound traffic from
# the `aws_lb` declared above.
resource "aws_security_group" "alb" {
  name = "alb-security-group"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_alb_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# The following resource is needed
# in order to enable inbound traffic to
# the `aws_instance`s declared above.
resource "aws_security_group" "instances" {
  name = "instance-security-group"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instances.id

  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  # The following line allows all IP address for this rule.
  cidr_blocks = ["0.0.0.0/0"]
}



# Make preparations for being able to tell the `aws_lb`
# to send traffic to the created `aws_instance`s (on the specified port).
resource "aws_lb_target_group" "instances" {
  name     = "example-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_1.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_2.id
  port             = 8080
}



# Set up and configure a load-balancer-listener "[aka an LB-listener]",
# to have inbound traffic coming from the web.
# (
# To keep things simple for this example,
# we are not going to set up an SSL certificate and HTTPS,
# but rather we are going to go with plain HTTP.
# )
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn

  port = 80

  protocol = "HTTP"

  # By default, return a simple 404 page.
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }
}



# resource "aws_route53_zone" "primary" {
#   name = "devopsdeployed.com"
# }

# resource "aws_route53_record" "root" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = "devopsdeployed.com"
#   type    = "A"

#   alias {
#     name                   = aws_lb.load_balancer.dns_name
#     zone_id                = aws_lb.load_balancer.zone_id
#     evaluate_target_health = true
#   }
# }
