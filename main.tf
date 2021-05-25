

# IHOR KARPIUK IT-13
module "frontend" {
  source = "./modules/s3/eu-central-1"
  context = module.base_labels.context
  name = "frontend"
}

module "dynamo_db_courses" {
  source = "./modules/dynamodb/eu-central-1"
  context = module.base_labels.context
  name = "courses"
}

module "dynamo_db_authors" {
  source = "./modules/dynamodb/eu-central-1"
  context = module.base_labels.context
  name = "authors"
}

module "iam" {
  source = "./modules/iam"
  context = module.base_labels.context
  name = "iam"
  dynamo_db_authors_arn = module.dynamo_db_authors.dynamo_db_arn
  dynamo_db_courses_arn = module.dynamo_db_courses.dynamo_db_arn
}

module "lambda" {
  source = "./modules/lambda/eu-central-1"
  context = module.base_labels.context
  name = "lambda"
  authors_role_arn = module.iam.authors_role_arn
  courses_role_arn = module.iam.courses_role_arn
  author_table_name =  module.dynamo_db_authors.dynamo_db_name
  course_table_name = module.dynamo_db_courses.dynamo_db_name
}

module "budget" {
  source = "./modules/budget"
  context = module.base_labels.context
  name = "budget"
  email_address = var.email_address
}

