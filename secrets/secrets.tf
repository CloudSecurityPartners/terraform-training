# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

terraform {
  backend "s3" {
    bucket = "hackgdl-2025"
    key    = "terraform/state/secrets.tfstate"
    region = "us-east-1"
    # Uncomment if you need DynamoDB state locking
    # dynamodb_table = "terraform-lock"
  }
}

# Create an AWS Secrets Manager secret
resource "aws_secretsmanager_secret" "example_secret" {
  name                    = "example-secret"
  description             = "Example secret created with Terraform"
  recovery_window_in_days = 7  # Number of days AWS Secrets Manager waits before permanent deletion
  
  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}

# Store secret value in the Secrets Manager secret
resource "aws_secretsmanager_secret_version" "example_secret_version" {
  secret_id     = aws_secretsmanager_secret.example_secret.id
  secret_string = jsonencode({
    username = "admin",
    password = "example-password",
    host     = "example-db-host",
    dbname   = "example-db",
    port     = "5432"
  })
}

# Optional: Create a resource policy for the secret
resource "aws_secretsmanager_secret_policy" "example_secret_policy" {
  secret_arn = aws_secretsmanager_secret.example_secret.arn
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "EnableAllPermissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "secretsmanager:*",
        Resource = "*"
      }
    ]
  })
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Output the secret ARN
output "secret_arn" {
  value       = aws_secretsmanager_secret.example_secret.arn
  description = "The ARN of the Secret Manager secret"
}

# Output the secret name
output "secret_name" {
  value       = aws_secretsmanager_secret.example_secret.name
  description = "The name of the Secret Manager secret"
}