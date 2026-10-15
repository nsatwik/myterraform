provider "aws" {
  region = "ap-south-1"
}

##Create ec2 instance
resource "aws_instance" "my_ec2" {
    tags = {
      Name = "terraform-ec2"
    }
    ami = "ami-01a00762f46d584a1"
    instance_type = "t3.micro"
    key_name = "terraform-key"
}


##Create S3 buckets
resource "aws_s3_bucket" "example" {
  bucket = "119307041364bucket"
}

