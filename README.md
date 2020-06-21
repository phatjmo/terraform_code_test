# terraform_code_test
Basic terraform code test demonstrating the build of an S3 bucket, EC2 instance, IAM role and requisite interactions. Built as a module.

## Cloud Eng Code Test

Create the following resources using Terraform:
* An S3 bucket
* An IAM role
* An IAM policy attached to the role that allows it to perform any S3 actions on that bucket and the objects in it
* An EC2 instance with the IAM role attached
* Output the public IP of the EC2 instance and the S3 bucket name.
Create a README.md and document all assumptions you’ve made. Login to the EC2 instance and validate that you’re able to access the bucket using the role.

