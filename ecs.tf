resource "aws_ecs_cluster" "omik-proj-cluster" {
  name = "omik-proj-cluster"
  setting {
    name = "containerInsights"
    value = "enabled"
  }
}

resource "aws_launch_configuration" "ecs" {
  image_id = "ami-06ca3ca175f37dd66"
  instance_type = "t3.medium"
  iam_instance_profile = aws_iam_instance_profile.omik-instance-profile.name
  security_groups = [ aws_security_group.omik-ecs-sg.id ]

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.omik-proj-cluster.name} >> /etc/ecs/ecs.config
              EOF
}

resource "aws_autoscaling_group" "ecs-autoscale" {
  count = length(var.cidr_pub_sub)
  desired_capacity = 2
  min_size = 2
  max_size = 4
  vpc_zone_identifier = [aws_subnet.omik-pub-subs[count.index].id, aws_subnet.omik-priv-subs[count.index].id]
  launch_configuration = aws_launch_configuration.ecs.id

  lifecycle {
    create_before_destroy = true
  }
}