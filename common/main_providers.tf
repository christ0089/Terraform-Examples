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
  function_name = "User_Balance"
}

resource "aws-lambda-functions" "transaction_service" {
  function_name = "User_Transactions"
}


resource "aws-lambda-functions" "Card_Manager" {
  function_name = "Card_Tockenization"
}



terraform {
  backend "s3" {}
}
