resource "aws_security_group" "omik-ecs-sg" {
  name        = "omik-ecs-sg"
  description = "allow traffic for ecs"
  vpc_id      = aws_vpc.omik-proj-vpc.id

  ingress {
    description = "Allow All"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
