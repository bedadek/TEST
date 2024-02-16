resource "aws_security_group" "cloudWebserverSecurityGroup" {
  name = "allow_ssh_hhtp"
  description = "Allow ssh http inbound traffic"
  vpc_id = var.cloud_vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port = ingress.value["port"]
      to_port = ingress.value["port"]
      protocol = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }

  egress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  } 
  
  tags = {
    //Name = "cloudWebserverSecurityGroup"
    Name = "AWSCloud-WebserverSecurityGroup"
    Project = "Demo"
  }
}

resource "aws_lb" "cloudLoadBalancer" {
  name = "web-app-lb"
  load_balancer_type = "application"
  subnets = [var.cloud_public_subnets[0].id, var.cloud_public_subnets[1].id]
  security_groups = [aws_security_group.cloudWebserverSecurityGroup.id]
  tags = {
    //Name = "cloudLoadBalancer"
    Name = "AWSCloud-LoadBalancer"
    Project = "Demo"
  }
}

resource "aws_lb_listener" "cloudLbListener" {
  load_balancer_arn = aws_lb.cloudLoadBalancer.arn

  port = 80
  protocol = "HTTP"
   
   default_action {
     target_group_arn = aws_lb_target_group.cloudTargetGroup.id
     type = "forward"
   }
}

resource "aws_lb_target_group" "cloudTargetGroup" {
  //name = "toff-target-group"
  name = "AWSCloud-TargetGroup"
  port = 80
  protocol = "HTTP"
  vpc_id = var.cloud_vpc_id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  tags = {
    //Name = "TargetGroup"
    Name = "AWSCloud-TargetGroup"
    Project = "Demo"
  }
}


resource "aws_lb_target_group_attachment" "TOFFwebserver1" {
  target_group_arn = aws_lb_target_group.cloudTargetGroup.arn
  target_id = aws_instance.TOFFwebserver1.id
  port = 80
}


resource "aws_lb_target_group_attachment" "TOFFwebserver2" {
  target_group_arn = aws_lb_target_group.cloudTargetGroup.arn
  target_id = aws_instance.TOFFwebserver2.id
  port = 80
}

resource "aws_instance" "TOFFwebserver1" {
  ami = local.ami_id
  instance_type = local.instance_type
  key_name = local.key_name
  subnet_id = var.cloud_public_subnets[0].id
  security_groups = [ aws_security_group.cloudWebserverSecurityGroup.id]
  associate_public_ip_address = true
  
  root_block_device {
    volume_size           = 30  # Change this to your desired volume size
    volume_type           = "gp2"
    encrypted             = true
  }

    tags = {
    //Name        = "Webserver-1"
    Name = "AWSCloud-Webserver"
    }
  
    user_data = <<-EOF
    #!/bin/bash -xe
    sudo su
    yum update -y
    yum install -y httpd

    # Download the ZIP file
    curl -o /tmp/eflyer.zip https://www.free-css.com/assets/files/free-css-templates/download/page287/eflyer.zip

    # Extract the ZIP file to the web server root directory
    unzip -o /tmp/eflyer.zip -d /var/www/

    # Start the web server
    service httpd start

    # Ensure the web server starts on boot
    chkconfig httpd on

    EOF
}

resource "aws_instance" "TOFFwebserver2" {
  ami = local.ami_id
  instance_type = local.instance_type
  key_name = local.key_name
  subnet_id = var.cloud_public_subnets[0].id
  security_groups = [ aws_security_group.cloudWebserverSecurityGroup.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 30  # Change this to your desired volume size
    volume_type           = "gp2"
    encrypted             = true
  }


  tags = {
    //Name        = "Webserver-2"
      Name = "AWSCloud-Webserver"

    }
  
     user_data = <<-EOF
    #!/bin/bash -xe
    sudo su
    yum update -y
    yum install -y httpd

    # Download the ZIP file
    curl -o /tmp/eflyer.zip https://www.free-css.com/assets/files/free-css-templates/download/page287/eflyer.zip

    # Extract the ZIP file to the web server root directory
    unzip -o /tmp/eflyer.zip -d /var/www/
    

    # Start the web server
    service httpd start

    # Ensure the web server starts on boot
    chkconfig httpd on

    EOF
}


resource "aws_autoscaling_group" "webserver_asg" {
  //name                 = "webserver-asg"
  name="AWSCloud-WebSever"
  max_size             = 5  # Maximum number of instances in the group
  min_size             = 1  # Minimum number of instances in the group
  desired_capacity     = 3  # Initial number of instances in the group
  launch_template {
    id      = aws_launch_template.webserver_lt.id
    version = "$Latest"
  }
  target_group_arns     = [aws_lb_target_group.cloudTargetGroup.arn]
  vpc_zone_identifier   = [var.cloud_public_subnets[0].id, var.cloud_public_subnets[1].id]
  health_check_type     = "ELB"
  health_check_grace_period = 300
  termination_policies  = ["OldestLaunchConfiguration"]

 tags = [
    {
      key                 = "Name"
      value               = "AWSCloud-Webserver"
      propagate_at_launch = true
    }
  ] 

}

resource "aws_launch_template" "webserver_lt" {
  //name_prefix = "webserver-template-"
   tags = {
    Name = "AWSCloud-WebserverLaunchTemplate"
    }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
      encrypted             = true

    }
  }
  instance_type = local.instance_type
  key_name = local.key_name
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.cloudWebserverSecurityGroup.id]
    subnet_id = var.cloud_public_subnets[0].id
  }
  image_id = "ami-0da5629beb988998e"
  user_data = base64encode(<<-EOF
        #!/bin/bash -xe
    sudo su
    yum update -y
    yum install -y httpd

    # Download the ZIP file
    curl -o /tmp/eflyer.zip https://www.free-css.com/assets/files/free-css-templates/download/page287/eflyer.zip

    # Extract the ZIP file to the web server root directory
    unzip -o /tmp/eflyer.zip -d /var/www/
    

    # Start the web server
    service httpd start

    # Ensure the web server starts on boot
    chkconfig httpd on

    EOF
  )
  
}

resource "aws_autoscaling_policy" "webserver_scaling_up" {
  name = "webserver-scaling-up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.webserver_asg.name
}

resource "aws_autoscaling_policy" "webserver_scaling_down" {
  name = "webserver-scaling-down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.webserver_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = "cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Scale up when CPU utilization is high"
  alarm_actions       = [aws_autoscaling_policy.webserver_scaling_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webserver_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  alarm_name          = "cpu-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Scale down when CPU utilization is low"
  alarm_actions       = [aws_autoscaling_policy.webserver_scaling_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webserver_asg.name
  }
}

//SNS and Cloudwatch
resource "aws_sns_topic" "notification_topic" {
  name = "EC2-Stop-Notification-Topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.notification_topic.arn
  protocol  = "email"
  endpoint  = "bedadek@gmail.com"  # Replace this with your email address
}

resource "aws_cloudwatch_metric_alarm" "ec2_instance_stopped_alarm" {
  alarm_name          = "EC2-Instance-Stopped-Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Maximum"
  threshold           = 1
  alarm_description   = "Alarm when EC2 instance is stopped"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webserver_asg.name
  }

  alarm_actions = [aws_sns_topic.notification_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_instance_started_alarm" {
  alarm_name          = "EC2-Instance-Started-Alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Alarm when EC2 instance is started"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webserver_asg.name
  }

  alarm_actions = [aws_sns_topic.notification_topic.arn]
}


//Rote 53 confriguation
/*resource "aws_route53_zone" "example_zone" {
  name = "awscloudservices.site"  # Change to your domain name
}
resource "aws_route53_record" "example_record" {
  zone_id = aws_route53_zone.example_zone.zone_id
  name    = "2300129"  # Change to the subdomain or domain name you want
  type    = "A"
  alias {
    name                   = aws_lb.cloudLoadBalancer.dns_name
    zone_id                = aws_lb.cloudLoadBalancer.zone_id
    evaluate_target_health = true
  }
}*/

//S3 and CDN

resource "aws_s3_bucket" "webserver_bucket" {
  bucket = "9960359594"
  acl    = "private"
}

resource "aws_cloudfront_distribution" "webserver_cdn" {
  origin {
    domain_name = aws_s3_bucket.webserver_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Web server CDN distribution"
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]  # Add the countries you want to whitelist
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }
  tags = {
    name = "AWSCloud-CDN"
  }
  price_class = "PriceClass_100"
}

