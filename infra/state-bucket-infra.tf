## use this to get bucket and lockstate
# terraform {
#   backend "local" {}
# }



// use this to create, un comment if needed 

# resource "aws_s3_bucket" "state_bucket" {
#   bucket = "foostatebucketstest3660418"
#   acl    = "private"

#   versioning {
#     enabled = true
#   }
# }

# resource "aws_dynamodb_table" "state_bucket_lock" {
#   name           = "foostatelock"
#   read_capacity  = 20
#   write_capacity = 20
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

