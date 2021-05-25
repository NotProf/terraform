module "labels" {
  source  = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
  context = var.context
  name    = var.name
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "this" {
  bucket        = "${data.aws_caller_identity.current.account_id}-${module.labels.id}"
  acl           = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"PublicRead",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${data.aws_caller_identity.current.account_id}-${module.labels.id}/*"]
    }
  ]
}

POLICY
  force_destroy = true
  tags          = module.labels.tags

  website {
    index_document = "index.html"
  }
}
