provider "aws" {
  region  = "${var.region}"
  version = "~> 1.36.0"
}

provider "template" {
  version = "~> 1.0.0"
}

provider "statuscake" {
  username = "${var.statuscake_username}"
  apikey   ="${var.statuscake_apikey}"
}


/*
Store infrastructure state in a remote store (instead of local machine):
https://www.terraform.io/docs/state/purpose.html
*/
terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    bucket  = "terraform-state-002"
    key     = "tvs/terraform.tfstate" # When using workspaces this changes to ':env/{terraform.workspace}/tvs/terraform.tfstate'
    region  = "eu-west-2"
    encrypt = "true"
  }
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  environment            = "${terraform.workspace}"
  project_name           = "${var.project_name}"
  slack_hook_url         = "${var.cloudwatch_slack_hook_url}"
  slack_channel          = "${var.cloudwatch_slack_channel}"
  ops_genie_api_key      = "${var.cloudwatch_ops_genie_api_key}"
}

module "cloudfront" {
  source = "./modules/cloudfront"

  environment                   = "${terraform.workspace}"
  project_name                  = "${var.project_name}"
  cloudfront_origin_domain_name = "${var.cloudfront_origin_domain_name}"
  cloudfront_aliases            = "${var.cloudfront_aliases}"
  cloudfront_certificate_arn    = "${var.cloudfront_certificate_arn}"
  offline_bucket_domain_name    = "${var.offline_bucket_domain_name}"
  offline_bucket_origin_path    = "${var.offline_bucket_origin_path}"
  domain                        = "${var.domain}"
}

module "statuscake" {
  source = "./modules/statuscake"

  environment              = "${terraform.workspace}"
  project_name             = "${var.project_name}"
  statuscake_alerts        = "${var.statuscake_alerts}"

}
