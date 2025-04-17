# Primary Lambda
resource "aws_lambda_function" "nebula_primary" {
  provider      = aws.primary
  function_name = "${var.project_name}-primary-function"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  filename      = "${path.module}/lambda_function.zip"

  environment {
    variables = {
      REGION = var.primary_region
    }
  }
}

# DR Lambda (disabled)
resource "aws_lambda_function" "dr" {
  provider      = aws.dr
  function_name = "${var.project_name}-dr-function"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  filename      = "${path.module}/lambda_function.zip"
  disabled      = true # Critical for pilot light

  environment {
    variables = {
      REGION = var.dr_region
    }
  }
}

# Sample Lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source {
    content  = <<EOF
def handler(event, context):
    print("Lambda executed in ${var.is_dr_region ? "DR" : "Primary"} mode")
    return {"statusCode": 200}
EOF
    filename = "index.py"
  }
}