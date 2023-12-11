resource "aws_s3_bucket" "uploads" {
  bucket = var.uploads_bucket
}

resource "aws_s3_bucket_acl" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  acl    = "private"
}

resource "aws_s3_bucket_cors_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["https://*.somleng.org"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "audio" {
  bucket = var.audio_bucket
}

resource "aws_s3_bucket_website_configuration" "audio" {
  bucket = aws_s3_bucket.audio.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_acl" "audio" {
  bucket = aws_s3_bucket.audio.id
  acl    = "public-read"
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
