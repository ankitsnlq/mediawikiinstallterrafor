# mediawikiaws
Installation of Media Wiki, Wiki forum on AWS using Terraform for Infra and Ansible for automated installation of Mediawiki.

# Requirements

- Terraform 
- Ansible
- AWS Cli
- AWS Programmatic Access IAM user. 
- Add access and secret key to your Laptop for AWS cli. 

# Steps Done by Terraform 

- Create VPC with 3 Private and 3 Public subnet.
- Create NAT gateway for Private subnet
- Create EC2 ssh key. 
- Create two security group one for web and another for DB.
- Create EC2 instance under private subnet with NAT Gateway and no outside access accept Mysql port access from Mediawiki webserver
- Create EC2 instance and run Ansible Playbook using local-exec feature of Terraform to start Mediawiki installation on webserver. 

# Steps Done by Ansible. 
- Install Apache2, Latest php with required php module required for Mediawiki. 
- Create Apache Vhost and remove default Vhost. 
- Download and extract Mediawiki installtion file to right folder.

# How to use this Repo to install Mediawiki. 

1. Clone this repo wherever you have terraform,Ansible and aws cli setup. 
2. Make sure IAM user have proper permission.
3. Make sure to edit variables.tf file on root folder of this project. 
4. Make sure to update `ssh_key_private` and `ssh_public_key` path to your private and public key on your Laptop which will be used for connecting to  Ec2 instances. 
5. Go to root dir of project and run command. 

         terraform init
         terraform plan
         terraform apply

6. After successfull installation Terraform will print public IP of webserver on your terminal access that IP on your Browser and do installation of Mediawiki and you can get connection details for Database under `install_mysql.sh` file. 

# TODO

- Snapshot Latest Webserver image and create ASG using this image. 
- Load Balancer. 
- Mysql master slave config or RDS. 
- Securing for Apache & Php installation. 

**Note: You can check screenshots folder for screenshot of my installation.**



