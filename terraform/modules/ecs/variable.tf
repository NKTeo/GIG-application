variable "vpc_id" {
    description = "The VPC ID"
}

variable "alb_sg_id" {
    description = "Load balancer security group ID"
}

variable "private_subnet_a_id" {
    description = "Private subnet a"
}

variable "private_subnet_b_id" {
    description = "Private subnet b"
}

variable "aws_lb_target_group_arn" {
    description = "Application load balancer target group ARN"
}