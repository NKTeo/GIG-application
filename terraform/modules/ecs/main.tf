# ECR
resource "aws_ecr_repository" "application_image_registry" {
    name = "application-image-registry"
}

# ECS Cluster
resource "aws_ecs_cluster" "application_cluster" {
    name = "application-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "application_task" {
    family                   = "application-task"
    container_definitions    = <<DEFINITION
    [
        {
        "name": "application-task",
        "image": "${aws_ecr_repository.application_image_registry.repository_url}",
        "essential": true,
        "portMappings": [
            {
                "containerPort": 3000,
                "hostPort": 3000
            }
        ],
        "memory": 512,
        "cpu": 256
        }
    ]
    DEFINITION
    requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
    network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
    memory                   = 512         # Specifying the memory our container requires (mandatory for Fargate)
    cpu                      = 256         # Specifying the CPU our container requires (mandatory for Fargate)
    execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}" # IAM grants tasks to access AWS resources
}

# ECS Service
resource "aws_ecs_service" "application_service" {
    name            = "application-service"
    cluster         = "${aws_ecs_cluster.application_cluster.id}"       # Referencing our created cluster
    task_definition = "${aws_ecs_task_definition.application_task.arn}" # Referencing the task our service will spin up
    launch_type     = "FARGATE"
    desired_count   = 3 # Setting the number of containers we want deployed

    load_balancer {
        target_group_arn = "${var.aws_lb_target_group_arn}" # Link ECS to LB by registering containers as target in target group
        container_name   = "${aws_ecs_task_definition.application_task.family}"
        container_port   = 3000 # Specifying the container port
    }

    network_configuration {
        subnets          = ["${var.private_subnet_a_id}", "${var.private_subnet_b_id}"]
        assign_public_ip = true # assign a public ip to each container
        security_groups  = ["${aws_security_group.service_security_group.id}"]
    }
}

# ECS security group
resource "aws_security_group" "service_security_group" {
    vpc_id      = "${var.vpc_id}"

    ingress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        # Only allowing traffic in from the load balancer security group
        security_groups = ["${var.alb_sg_id}"]
    }

    egress {
        from_port   = 0 # Allowing any incoming port
        to_port     = 0 # Allowing any outgoing port
        protocol    = "-1" # Allowing any outgoing protocol 
        cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
    }
}

# SECURITY (IAM ACCESS)
resource "aws_iam_role" "ecsTaskExecutionRole" {
    name               = "ecsTaskExecutionRole"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy_ecs.json}"
}

data "aws_iam_policy_document" "assume_role_policy_ecs" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
    role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}