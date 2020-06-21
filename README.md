![tflint](https://github.com/phatjmo/terraform_code_test/workflows/tflint/badge.svg)
![tfsec](https://github.com/phatjmo/terraform_code_test/workflows/tfsec/badge.svg)

# terraform_code_test
Basic terraform code test demonstrating the build of an S3 bucket, EC2 instance, IAM role and requisite interactions. Built as a module.

## Requirements

Create the following resources using Terraform:
* An S3 bucket
* An IAM role
* An IAM policy attached to the role that allows it to perform any S3 actions on that bucket and the objects in it
* An EC2 instance with the IAM role attached
* Output the public IP of the EC2 instance and the S3 bucket name.
Create a README.md and document all assumptions you’ve made. Login to the EC2 instance and validate that you’re able to access the bucket using the role.

## Assumptions

* S3 bucket policy and assumed role access should be explicit but not exclusive and otherwise private
* Construct as a module for use in other projects and provide implementation example
* Construct tests proving that EC2 instance is accessible and that it is able to create/list/delete objects under the specified bucket
* Provide input variables for flexible implementation with defaults that permit minimal configuration and allows for dependency inversion on key networking infrastructure such as preferred VPC.

## Examples
An [example](./examples/ImportAndTestConnection/README.md) has been provided that imports the module and tests both SSH and S3 access using remote-exec.

#### ImportAndTestConnection: `./examples/ImportAndTestConnection`

```hcl
module "InstanceWithBucket" {
    source = "../../"

    ssh_permit = ["<your_ip_address>/32"]
    make_public = true
    public_key_path = "~/.ssh/id_rsa.pub"

}

//Print out Module Outputs
resource "null_resource" "example" {
    provisioner "local-exec" {
        command = "echo Public IP: ${module.InstanceWithBucket.public_ip}\n && echo Bucket Name: ${module.InstanceWithBucket.bucket_name}\n"
    }
}
```