# Nginx with backend configuration file
## Problem
Where a DNS is not available; only IP addresses.
## Solution
Use a Lambda to query 1+n DNS names and insert the resulting IP addresses into the backend file. Re-start the containers.  

## Commands
$ aws deploy create-deployment --cli-input-yaml file://service-a-appspec.yaml  

Build for the AWS linux platform, tag and push all in one.  
$ docker buildx build --platform linux/amd64,linux/arm64 --push -t 107404535822.dkr.ecr.eu-west-2.amazonaws.com/nginx-service-a:latest .
$ docker buildx build --platform linux/amd64,linux/arm64 --push -t 107404535822.dkr.ecr.eu-west-2.amazonaws.com/nginx-service-a:latest .
