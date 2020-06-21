provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

locals {
  public_key_path  = "~/.ssh/id_rsa.pub"
  private_key_path = "~/.ssh/id_rsa"
}

data "http" "user_ip" {
  url = "http://ipv4.icanhazip.com"
}

module "InstanceWithBucket" {
  source = "../../"

  ssh_permit      = ["${chomp(data.http.user_ip.body)}/32"]
  make_public     = true
  public_key_path = "~/.ssh/id_rsa.pub"

}

resource "null_resource" "test_ssh_s3" {
  //Attempt to connect to the instance and perform operations on S3 bucket.
  //Connection attempts will timeout after 5 minutes
  connection {
    host        = module.InstanceWithBucket.public_ip
    user        = "ec2-user"
    private_key = file(local.private_key_path)
  }

  provisioner "file" {
    source      = "./test-object.txt"
    destination = "/tmp/test-object.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "aws s3 cp /tmp/test-object.txt s3://${module.InstanceWithBucket.bucket_name}",
      "aws s3 ls s3://${module.InstanceWithBucket.bucket_name}",
      "aws s3api --output text get-object --bucket ${module.InstanceWithBucket.bucket_name} --key test-object.txt /dev/stdout",
      "aws s3 rm s3://${module.InstanceWithBucket.bucket_name}/test-object.txt"
    ]

  }
}

