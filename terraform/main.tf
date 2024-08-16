# Configuração do Provider AWS
provider "aws" {
  region = "us-east-1"
}

# VPC (para o ECS e EKS)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Subnet para o ECS e EKS
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block  = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Grupo de Segurança
resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id
}

# EKS Cluster
resource "aws_eks_cluster" "app_web" {
  name     = "app-web-cluster"
  role_arn  = aws_iam_role.eks.arn
  version   = "1.21"

  vpc_config {
    subnet_ids = [aws_subnet.main.id]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "servico_pedido" {
  name = "servico-pedido-cluster"
}

# SQS Queue
resource "aws_sqs_queue" "fila_pedidos" {
  name = "fila-pedidos"
}

# Lambda Execution Role
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

# Lambda Functions
resource "aws_lambda_function" "processador_pedido_1" {
  filename      = "path/to/your/lambda_function_1.zip"
  function_name = "processador_pedido_1"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.8"
}

resource "aws_lambda_function" "processador_pedido_2" {
  filename      = "path/to/your/lambda_function_2.zip"
  function_name = "processador_pedido_2"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.8"
}

# S3 Buckets
resource "aws_s3_bucket" "estoque_bombons" {
  bucket = "estoque-bombons"
}

resource "aws_s3_bucket" "dados_analiticos" {
  bucket = "dados-analiticos"
}

# RDS Database
resource "aws_db_instance" "historico_pedidos" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  name                 = "historico_pedidos"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main.id]
}

# Subnet group for RDS
resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.main.id]
}

# IAM Role for EKS
resource "aws_iam_role" "eks" {
  name = "eks_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "eks.amazonaws.com",
        },
      },
    ],
  })
}

# Outputs
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.app_web.endpoint
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.servico_pedido.name
}

output "sqs_queue_url" {
  value = aws_sqs_queue.fila_pedidos.id
}

output "s3_bucket_estoque_bombons" {
  value = aws_s3_bucket.estoque_bombons.bucket
}

output "s3_bucket_dados_analiticos" {
  value = aws_s3_bucket.dados_analiticos.bucket
}

output "rds_instance_endpoint" {
  value = aws_db_instance.historico_pedidos.endpoint
}
