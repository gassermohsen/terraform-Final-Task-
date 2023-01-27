provider "aws" {
  shared_credentials_files = ["/home/gasser/.aws/credentials"]
  profile                  = "terraform"
  region = "us-east-1"
}
