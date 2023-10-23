output "dynamodb_table" {
  value       = aws_dynamodb_table.table
  description = "The DynamoDB table"
}
