resource "aws_s3_bucket" "images" {
  bucket        = "wishifai-images-${var.candidate_number}"
  force_destroy = true
}