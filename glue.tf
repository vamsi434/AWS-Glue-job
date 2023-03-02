provider "aws" {
    region = "us-east-1"
}
resource "aws_iam_role" "glue_role" {
  name = "glue-job-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy" "glue_role_policy" {
  name = "glue_job_role_policy"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessToEC2",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowAccessToCloudWatchLogs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": "*"
        }
    ]
}
)
}
resource "aws_glue_job" "notebook_job" {
  name         = "${var.glue_job_name}"
  role_arn     = aws_iam_role.glue_role.arn
  glue_version = "1.0"
  execution_class = "STANDARD"
  command {
    name       = "pythonshell"
    python_version = "3"
    script_location = "s3://${aws_s3_bucket.notebook_bucket.id}/target/my_script.py"
}
   default_arguments = {
     "--job-language" = "python"
     "--enable-job-insights" = "false"
     "--enable-glue-datacatalog" = "true"
   }
   execution_property {
    max_concurrent_runs = 1
  }

  timeout = 60

  tags = {
    Environment = "test"
  }
}
resource "null_resource" "jupyter_notebook_conversion" {
  depends_on = [aws_glue_job.notebook_job]
  provisioner "local-exec" {
    command = "aws glue start-job-run --job-name ${var.glue_job_name}"
    working_dir = "${path.module}"
  }
}
resource "aws_s3_bucket" "notebook_bucket" {
  bucket = "vamsi-notebook-bucket"
}
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.notebook_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

