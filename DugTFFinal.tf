terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "myS3Bucket" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_iam_role" "myRole" {
  name = "myRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "mySG inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description      = "Connect to DB"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow"
  }
}

resource "aws_db_instance" "myrds" {
  allocated_storage    = 20
  db_name              = "metroddb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.rdssubnetgroup.id
  multi_az = true
  vpc_security_group_ids = [aws_security_group.mySG.id]
}

resource "aws_glue_job" "myGlueJob"
  name     = "myGlueJob
  role_arn = aws_iam_role.example.arn

  command {
    script_location = "s3://${aws_s3_bucket.example.bucket}/myGlueJob.py"
  }
}

data "aws_kms_key" "by_id" {
  key_id = "1234abcd-12ab-34cd-56ef-1234567890ab"
}

resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = 
}

resource "aws_lb" "webalb" {
  name               = "webalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_mySG.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.mySubnet1.id]

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.webalb.arn
  port              = "80"
  protocol          = "HTTP"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_lb_listener" "Internal" {
  load_balancer_arn = aws_lb.webalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webalbtg.arn
  }
}

Resource "aws_launch_template" "Ltemplate" {
  name = "MyASGLaunch-Template"

  image_id = "ami-04a7352d22a23c770"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ec2KeyPair.id
  vpc_security_group_ids = [aws_security_group.ec2_mySG.id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Web"
    }
  }
#   user_data = filebase64("${path.module}/bootstrap.sh")
}
# Create an Autoscaling group
resource "aws_autoscaling_group" "myASG" {
  name                      = "myASG"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.mySubNet1.id]

  initial_lifecycle_hook {
    name                 = "MyLCH"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    notification_metadata = jsonencode({
       = "bar"
    })

    notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  }

  tag {
    key                 = "name
    value               = "myASG
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}

