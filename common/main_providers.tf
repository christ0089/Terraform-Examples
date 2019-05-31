provider "aws" {
  region = "eu-west-1"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}


provider "aws" {
  region = "us-central-1"
}

resource "aws-lambda-functions" "balance_service" {
  function_name = "lambda-3-${substr("${local.api_artifact_name}", 0, min(64, length(local.api_artifact_name)))}"

  runtime = "nodejs8.10"
  # "index" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "lambda-3/balance.api"


  # Optional, but ensures that things don't constantly refresh during local development
  source_code_hash = "${base64sha256(file("${local.api_dist_dir}"))}"
}

resource "aws-lambda-functions" "transaction_service" {
  function_name = "lambda-1-${substr("${local.api_artifact_name}", 0, min(64, length(local.api_artifact_name)))}"


  runtime = "nodejs8.10"

 handler = "lambda-3/transaction.api"

  # Optional, but ensures that things don't constantly refresh during local development
  source_code_hash = "${base64sha256(file("${local.api_dist_dir}"))}"

}


resource "aws-lambda-functions" "Card_Manager" {
  function_name = "lambda-2-${substr("${local.api_artifact_name}", 0, min(64, length(local.api_artifact_name)))}"


  runtime = "nodejs8.10"

  # "index" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "lambda-2/card_manager.api"

  # Optional, but ensures that things don't constantly refresh during local development
  source_code_hash = "${base64sha256(file("${local.api_dist_dir}"))}"
}



terraform {
  backend "s3" {}
}
