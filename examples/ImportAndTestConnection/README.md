# Import and Test Module
This example shows a basic implementation of the InstanceAndBucket module:
1. Grab the public IP address of the executing user
2. Specify the local public and private key to import for SSH
3. Import the module providing the current user's public IP and local keys
4. Upload a basic text file for use in testing S3 permissions
5. Connect to the created instance and test:
   1. List the created bucket
   2. Put test-object.txt on the created bucket
   3. Get test-object.txt from the created bucket and output to STDOUT
   4. Delete test-object.txt from the created bucket

##### Note: If the delete fails, terraform destroy will fail because the bucket won't be empty