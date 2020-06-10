resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "S3" {
  name        = "S3-policy"
  description = "Access to kaggle bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "S3_attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.S3.arn
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "/local-git/infra/lambda/resources/resources.zip"
  function_name = "lambda_from_terraform"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "test.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("/local-git/infra/lambda/resources/resources.zip")

  runtime = "python3.7"

  environment {
    variables = {
      HOME = "/tmp"
      KAGGLE_USERNAME = ""
      KAGGLE_KEY = ""
    }
  }
}