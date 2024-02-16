# Deploying-a-resilient-reliable-and-highly-scalable-server-based-cloud-infrastructure
# Provisioning-a-Webserver-Infrastructure-using-Terraform
![Deploying architecture (3)](https://github.com/kingtoff/Deploying-a-scalable-AWS-cloud-infrastructure-using-terraform/assets/99415191/0455a3e2-4a07-4f34-8001-925f647a1541)

### This repository contains the Terraform code and configuration files to deploy a 3-tier web application on AWS. The application consists of a frontend web server, a backend application server, and a database server, all deployed in separate EC2 instances.

## Prerequisites
## Before deploying the infrastructure, we will need to have the following tools and resources:

1. An AWS account
2. Terraform installed on your local machine
3. AWS credentials configured on your local machine
4. An SSH keypair to access the EC2 instances
### Getting Started
1. Clone this repository to your local machine.
2. Navigate to the terraform directory.
3. Run terraform init to initialize the Terraform configuration.
4. Run terraform apply to deploy the infrastructure.
Once the deployment is complete, we can access the frontend web server by navigating to the public IP address of the web server instance in your web browser.
## Architecture
### The 3-tier web application is deployed using the following architecture:

1. The frontend web server is deployed in a public subnet and is accessible via an Elastic IP address.
2. The database server is deployed in a private subnet and is not accessible from the internet.
3. All instances are deployed using Amazon Linux 2 and are running the latest version of the required software.

## Resources Created
### The following AWS resources are created by the Terraform code and the functions they hold:

### 1. 1 VPC with 4 subnets (2 public, 2 private)
To build a scalable infrastructure, it is neccessary we start our plan from the VPC, 
 The VPC: is the logical isolated environment provided for you in the cloud to deploy your resources which in simple terms means your cloud space which your cloud or on premise infrastructure are being provisioned. We created subnets inorder to divide our resources into the ones that will be exposed to the public internet and the ones that will be shielded from the public but will nervertheless use the internet

2. 1 Internet Gateway: the internet gateway is for communications between the resources in the VPC and the internet. it is most times routed to the customer-facing layers such as the webserver application for internet accessibility.
3. 2 Elastic IP address: the EIP will be allocated to the two NAT Gateway we created 
4. 2 NAT Gateway : is a highly available AWS managed service that creates a network communication between the Internet and instances within a private subnet in an Amazon Virtual Private Cloud (Amazon VPC) and it routed through public subnet and not directly to the internet like the Internet Gateway
5. 2 EC2 instances: the EC2 instances will be hosting our apache webserver, we have two instances each spinned up in different availability zones to avoid server downtime. This is a best practice to improve scalabilty and reliabilty.
6. Security groups: to control traffic to and from the instances
7. RDS Database: is a database for storing structured data 
8. Application Load Balancer: the ALB automatically routes traffic from users to the instances in the availability zones for scalability and reliability of the servers to avoid downtimes


## Customization
You can customize the deployment by modifying the variables in the variables file. You can also modify the Terraform code to add or remove resources, or change the configuration of existing
 resources.

## Clean Up
To delete the infrastructure to avoid incurring unnecessary bills, run terraform destroy. This will delete all resources created by the Terraform code. Note that this cannot be undone, so make sure you really want to delete the infrastructure before running this command.

## Finally on Terraform
This Terraform code provides an easy and repeatable way to deploy a 3-tier web application on AWS. You can use it as a starting point for your own projects, or modify it to fit your specific needs. 
