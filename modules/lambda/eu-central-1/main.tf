module "labels" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
  context = var.context
  name = var.name
}


data "archive_file" "get_all_authors" {
  type = "zip"
  source_file = "${path.module}/js/get-all-authors.js"
  output_path = "${path.module}/zip/get-all-authors.zip"
}

resource "aws_lambda_function" "get-all-authors" {
  filename = data.archive_file.get_all_authors.output_path
  function_name = "get-all-authors"
  role = var.authors_role_arn
  handler = "get-all-authors.handler"

  runtime = "nodejs14.x"

  environment {
    variables = {
      "TABLE_NAME" = var.author_table_name
    }
  }
}

locals {
  course_lambda_settings = [
    {
      function_name: "get-all-courses",
      handler: "get-all-courses.handler",
    },
    {
      function_name: "get-course",
      handler: "get-course.handler",
    },
    {
      function_name: "save-course",
      handler: "save-course.handler",
    },
    {
      function_name: "update-course",
      handler: "update-course.handler",
    },
    {
      function_name: "delete-course",
      handler: "delete-course.handler",
    },
  ]
}

data "archive_file" "course_files" {
  count = 5
  type = "zip"
  source_file = "${path.module}/js/${local.course_lambda_settings[count.index].function_name}.js"
  output_path = "${path.module}/zip/${local.course_lambda_settings[count.index].function_name}.zip"
}
resource "aws_lambda_function" "courses" {
  count = 5
  filename = data.archive_file.course_files[count.index].output_path
  function_name = local.course_lambda_settings[count.index].function_name
  role = var.courses_role_arn
  handler = local.course_lambda_settings[count.index].handler
  runtime = "nodejs14.x"

  environment {
    variables = {
      "TABLE_NAME" = var.course_table_name
    }
  }
}
