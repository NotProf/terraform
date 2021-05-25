output "authors_role_arn" {
  value = aws_iam_role.authors_role.arn
}

output "courses_role_arn" {
  value = aws_iam_role.course_role.arn
}
