# LOAD BALANCER
resource "aws_alb" "application_load_balancer" {
    name               = "application-alb-tf"
    load_balancer_type = "application"
    subnets = [
        "${var.public_subnet_a_id}",
        "${var.public_subnet_b_id}"
    ]
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_security_group" "load_balancer_security_group" {
    vpc_id      = "${var.vpc_id}"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
    }

    egress {
        from_port   = 0 # Allowing any incoming port
        to_port     = 0 # Allowing any outgoing port
        protocol    = "-1" # Allowing any outgoing protocol 
        cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
    }
}

# Traffic routing (load balancer to ECS service targets)
resource "aws_lb_target_group" "application_target_group" {
    name        = "application-target-group"
    port        = 80
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = "${var.vpc_id}"
    health_check {
        matcher = "200,301,302"
        path = "/"
    }
}

resource "aws_lb_listener" "application_listener" { # distributes incoming application traffic across multiple targets
    load_balancer_arn = "${aws_alb.application_load_balancer.arn}"
    port              = "80"
    protocol          = "HTTP"
    default_action {
        type             = "forward"
        target_group_arn = "${aws_lb_target_group.application_target_group.arn}"
    }
}