resource "aws_s3_bucket" "uploads" {
  bucket = var.uploads_bucket
  acl    = "private"
  region = var.aws_region

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["https://*.somleng.org"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "audio" {
  bucket = var.audio_bucket
  acl    = "public-read"
  region = var.aws_region
}

resource "aws_s3_bucket_policy" "audio" {
  bucket = aws_s3_bucket.audio.id

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.audio.arn}/*"
      ]
    }
  ]
}
  POLICY
}