module "vpc-terraform" {

    source = "./vpc & igw"
    vpc-cidr = "10.0.0.0/16"
    vpc-name = "Terraform"
  
}


module "subnet" {
  source = "./subnet"
  vpc-id = module.vpc-terraform.vpc-id
  subnet-cidr = ["10.0.0.0/24","10.0.2.0/24","10.0.1.0/24","10.0.3.0/24"] 
  subnet-names = ["public subnet 1" ,"public subnet 2 ", "private subnet 1" , "private subnet 2"  ]
  availability_zone = ["us-east-1a", "us-east-1b" , "us-east-1a", "us-east-1b"]
}


module "routTables" { 
  source = "./routetables"
  vpc-id = module.vpc-terraform.vpc-id
  all-trafic-cidr = "0.0.0.0/0"
  internet-gateway-id = module.vpc-terraform.internetgateway-id
  public-subnet-assos-1 = module.subnet.subnets-ids[0]
  public-subnet-assos-2 = module.subnet.subnets-ids[1]
  nat-private-subnet-assos-1 = module.subnet.subnets-ids[2]
  nat-private-subnet-assos-2 = module.subnet.subnets-ids[3]
  nat_gateway_id = module.natGatway.nat-id
}


module "ec2" {
    source = "./ec2"
    vpc_id = module.vpc-terraform.vpc-id
    all-trafic-cidr = "0.0.0.0/0"
    default-ami = "ami-06878d265978313ca"
    default-instance-type = "t2.micro"
    public_subnet_id = [module.subnet.subnets-ids[0],module.subnet.subnets-ids[1]]
    #Provisioner for public ec2s
    provisioner-remote-exec-inline = ["sudo apt update -y",
      "sudo apt install -y nginx",
      "echo 'server { \n listen 80 default_server; \n  listen [::]:80 default_server; \n  server_name _; \n  location / { \n  proxy_pass http://${module.NLP.nlp_dns}; \n  } \n}' > default",
      "sudo mv default /etc/nginx/sites-enabled/default",
      "sudo systemctl stop nginx",
      "sudo systemctl start nginx",]
      
    private_subnet_id = [module.subnet.subnets-ids[2],module.subnet.subnets-ids[3]]
}

module "natGatway" {
  source = "./nategatway"
  subnet-for-the-nat = module.subnet.subnets-ids[0]
}


module "ALP" {
  source = "./ALP"
  ALP_name = "Public-ALP"
  vpc_id = module.vpc-terraform.vpc-id
  tg_ec2_ids = module.ec2.aws_public_instance-ip
  public_subnet_ids = [module.subnet.subnets-ids[0],module.subnet.subnets-ids[1]]

}


module "NLP" {
  source = "./NLP"
  NLP_name = "Private-NLP"
  vpc_id = module.vpc-terraform.vpc-id
  tg_private-ec2_ids = module.ec2.aws_private_instance-ip
  private_subnet_ids = [module.subnet.subnets-ids[2],module.subnet.subnets-ids[3]]
}


