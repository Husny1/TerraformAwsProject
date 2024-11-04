# COSC2759 Assignment 2

## Student details

- Full Name: Huseyin Bator
- Student ID: s3660418
## important note
`` note: my name is spelt incorrectly in AWS learning lab as huyesyin ``
`` note: Completed only up to section ``
`` note: couldve used secure ports but i kept running into endless errors``


## Solution design
My solution consists of a Terraform automated system that handles both the infrastructure automation and application deployment. Based on the specifications provided by Alpine Inc, I have implemented an automated infrastructure using the resources provided by Alpine to create a streamlined process.

The Foo database is hosted on its own EC2 instance within AWS. it is running a PostgreSQL database using the official Docker image provided by Alpine Inc. This instance is configured with open ports to allow communication with the application containers.
`` note: couldve used secure ports but i kept running into endless errors``

The application containers are on 2 seperate instances in which they can share the incoming traffic to the site equally via a load balancer. The load balancer distrubetes the load of traffic evenly amongst the two application EC2s in place. 

The Node.JS app used in the containers that are pulled from mattcul/assignment2app docker image.

Ansible configures the containers and deploys those to the appointed EC2 instance in which. Ansible Playbooks also install the relavent dependencies to run the containers succesfully. The application is connected via Private IPv4 to the database application in which it is directed as the host. 

``state-bucket-infra.tf`` File is used for generating a state lock and bucket if neccesary. Utilise that if it is needed. S3 backend remote has been configured in the ``Main.tf`` which sends terraform.tfstate and footstate.lock to the appointed dynamodb location and bucket.

### Infrastructure
![infastructure](/img/infra.png)
The image provided is a representation of how the created IaC works, From the client all the way to the backend container.

Heres how it works: 

Client requests are routed through an Internet Gateway which is configured in the `alb.tf` file. This then talks to the Virtual Private Cloud (VPC) Which then comminucates to AWS. The VPC (10.0.0.0/16) provides an isolated network for cloud resources and allocates a spefic amount of subnets to the instances. 

Incoming traffic is first handled by an Application Load Balancer (ALB) (alb.tf), which distributes requests across the two applicatioon EC2 instances that hold the applications. The ALB and PostGreSQL are using secuirty groups to allow HTTP and SSH access.

The application runs on two EC2 instances (instance_a and instance_b) which are pulled images from the docker container provided by Alpine inc. They have specific CDIR Blocks they must adhere to. Each instance has a public IP and is protected by security groups that go through the  SSH (port 22) and HTTP. Tags like "App1" instance" and "App2 instance help identify the resources and ensure reusability for the next developer to make improvements to the code.

For database backend, the PostgresSQL instance (instance_c) is configured with restricted access through the DBSecGroup, allowing database traffic only on port 5432. 


#### Key data flows
Client: 
    A client sends an HTTP/HTTPS request over the internet by typing in the web address. This is routed through the internet gateway that is configured by the route table. As we are still in testing phase the CIDR  ``cidr_block = "0.0.0.0/0"`` is open to everyone.  
    |
    |
    V
Load Balancer:
    Then the request met by the Application Load Balancer (ALB), which is responsible for distributing traffic across to the applicationr EC2 instances that are hosting the application. The ALB uses 
    |
    |
    V
```hcl security_groups = [
  aws_security_group.ALBSecGroup.id,
  aws_security_group.DBSecGroup.id
]
```
ALBSecGroup: This security group allows HTTP (port 80) and SSH (port 22) access.

DBSecGroup: This security group is also attached to the ALB
    |
    |
    V
Application Containers:
    Once the ALB forwards the request and reaches the two EC2 instances (instance_a and instance_b) through the public IP Adress, Communication will begin with the Database instances Private Ip. 
    |
    |
    V
Database Interaction:
   the application instances make a request to the PostgreSQL database hosted on another EC2 instance (instance_c).

This is all relayed back to the client in reverse order starting from the DB container (EC2). As shown below (key data flow): 


![dataflow](/img/flowchart.png)



### Deployment process
To deploy the infastructure you can take the following steps: 


First you will need the prerequesits and installed:

#### Prerequisites
 - AWS learning Lab
 - Terraform 
 - Docker
 - Powershell 
 - Ansible
 - IAMI user
 - VS code 

### WITHOUT .SH 
 Get your AWS credentials 

1: Get Your AWS Credentials
Get your AWS credentials and assign them in the terraform.tfvars file:
```
aws_access_key = "your_access_key"
aws_secret_key = "your_secret_key"
aws_session_token = "your_session_token" 
```

2: Get a Key Pair
Create a private key named `privatekey.pem` so Ansible to connect to the infrastructure as its set as privatekey.pem:
``` ssh-keygen -t rsa -b 4096 -f privatekey.pem ```

3: Deploy with Terraform
In your terminal, run the following:
```terraform init ```  
validate the terraform
```terraform validate```
View the plan
```terrafrom plan ``` 
Deploy infrastructure:
```terraform apply    ```

4: Configure with Ansible
Once Terraform creates the infrastructure, run Ansible:
ansible-playbook playbook2.yml -i inventory2.yml --private-key ~/path/to/privatekey.pem

`` If you run into errors whilst running playbook try reconfiguring Playbook2 ``

5: Access the Application
Upon completion, the ALB and containers will be running on AWS and you can access the application/database by entering the public IP of the AppContainers which are generated in Inventory2.yml


#### Validating that the app is working
![logs](/img/instances.png)
![logs](/img/sectionbinstance.png)
![logs](/img/successfulb.png)
![logs](/img/successfulb.png)
![logs](/img/successfulb.png)
![log2](/img/log2.png)
![logandip1](/img/logandip2.png)
![logandip2](/img/logandip.png)
![logandip3](/img/imthings.png)
![lockstate](/img/lockstate.png)
![lockstate22](/img/sectionca.png) 
![lockstate](/img/bucketfile.png)
![lockstate24](/img/lcokstate.png)
![lockstate24](/img/alb.png)

## Contents of this repo directory

### Ansible:
- **debug.yml**: Ansible playbook for debugging tasks.
- **playbook.yml**: playbook used for Section A, ansible config script.
- **playbook2.yml**: playbook used for Section B, ansibla config scriat.

### App:
- **Dockerfile**: instructions for building Docker container.
- **index.js**: main Node.js application.
- **package.json**: App Dependencies.

### Data:
- **snapshot-prod-data.sql**: production database files.

### Imgs:
- **Screenshots of completed task**:

### Misc:
- **how-to-build-app-docker-image.txt**: key insstrunctions for docker image install provided by alpine.
- **how-to-deploy.txt**: steps for deploying.
- **state-bucket-infra.tf**: Use this file if no S3 has been initialized for yourself.
- **terraform.lock.hcl**: Lockfile for Terraform module versions.

### Root:
- **AlbTarget.tf**: Load Balancer target only resource and configuration.
- **ansible-config.tf**: Ansible global config file.
- **inventory1.yml**: Section A hosts, IP, dependencies ,containers install and config.
- **inventory2.yml**: Section B hosts, IP, dependencies ,containers install and config.
- **main.tf**: Main Terraform configuration file, includes S3 config and Section A instance.
- **nginx-config.conf**: Nginx web server configuration (optional usage).
- **outputs.tf**: All Terraform outputs.
- **terraform.tfvars**: Variables for the Terraform configuration.

# References 
In the terraform/Ansible files code blocks the documentation that have been used to assist me throughout have been commented in line with the block.
# S3660418-Assignment_2
