resource "aws_s3_bucket" "group3-s3-utility-bucket-test" {
  bucket = var.bucket_name
  acl    = "private"
  tags = var.s3_tags

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "log/"

    tags = {
      "rule"      = "log"
      "autoclean" = "true"
    }


    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 1825  # 5 years
    }
  }
}
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "group3-mybucket12345678912345678" {
  bucket = "group3-mybucket12345678912345678"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}