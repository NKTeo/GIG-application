output "alb_arn" {
    value = "${aws_alb.application_load_balancer.arn}"
}

output "alb_sg_id" {
    value = "${aws_security_group.load_balancer_security_group.id}"
}

output "aws_lb_target_group_arn" {
    value = "${aws_lb_target_group.application_target_group.arn}"
}

output "load_balancer_dns_name" {
    value = "${aws_alb.application_load_balancer.dns_name}"
}