module "networking" {
    source = "./modules/networking"
    environment = "${var.environment}"
    vpc_id = module.networking.vpc_id
}

module "ecs" {
    source = "./modules/ecs"
    vpc_id = module.networking.vpc_id
    alb_sg_id = module.load-balancer.alb_sg_id
    private_subnet_a_id = module.networking.private_subnet_a_id
    private_subnet_b_id = module.networking.private_subnet_b_id
    aws_lb_target_group_arn = module.load-balancer.aws_lb_target_group_arn
}

module "load-balancer" {
    source = "./modules/load-balancer"
    vpc_id = module.networking.vpc_id
    public_subnet_a_id = module.networking.public_subnet_a_id
    public_subnet_b_id = module.networking.public_subnet_b_id
}

module "waf" {
    source = "./modules/waf"
    alb_arn = module.load-balancer.alb_arn
}

output "web_application_link" {
    value = module.load-balancer.load_balancer_dns_name
}