resource "aws_ecr_repository" "omik-ecr" {
  name                 = "omik-server"
  image_tag_mutability = "MUTABLE"

  provisioner "local-exec" {
    command = <<-EOF
              cd /home/omik/Desktop/node_crud
              aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.omik-ecr.repository_url}
              docker build -t ${aws_ecr_repository.omik-ecr.name} .
              docker tag ${aws_ecr_repository.omik-ecr.name}:latest ${aws_ecr_repository.omik-ecr.repository_url}/${aws_ecr_repository.omik-ecr.name}:latest
              docker push ${aws_ecr_repository.omik-ecr.repository_url}/${aws_ecr_repository.omik-ecr.name}:latest
              EOF
  }
}

