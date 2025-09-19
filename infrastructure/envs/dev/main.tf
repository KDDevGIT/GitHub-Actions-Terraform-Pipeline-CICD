module "example" {
  source = "../../modules/bucket"
  bucket_name = var.bucket_name 
}

variable "bucket_name" {
  type = string
}