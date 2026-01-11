provider "aws" {
  region = "eu-north-1" 
}

resource "aws_s3_bucket" "audit_bucket" {
  bucket_prefix = "security-audit-lab-" 
  force_destroy = true # Allows deleting bucket even if not empty
}

resource "aws_sns_topic" "alerts" {
  name = "security-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "husele1000@gmail.com" # <--- PUT YOUR EMAIL HERE
}


resource "aws_iam_role" "lambda_role" {
  name = "auditor_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "auditor_lambda_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = ["s3:GetObject"]
        Effect = "Allow"
        Resource = "${aws_s3_bucket.audit_bucket.arn}/*"
      },
      {
        Action = ["sns:Publish"]
        Effect = "Allow"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Zips your Python code automatically
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "audit.py"
  output_path = "audit.zip"
}

resource "aws_lambda_function" "auditor" {
  filename         = "audit.zip"
  function_name    = "SecurityAuditor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "audit.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }
}

# Permission for S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auditor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.audit_bucket.arn
}

# Connect the Bucket to the Lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.audit_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.auditor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

# --- Outputs ---
output "bucket_name" {
  value = aws_s3_bucket.audit_bucket.id
}