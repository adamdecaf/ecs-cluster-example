variable "ecs_cluster_id" { }

variable "redis_docker_image" {
  # todo: depend on concat+output from other resource
  default = "741412628301.dkr.ecr.us-east-1.amazonaws.com/redis:3.2"
}

# todo: move to an example

resource "template_file" "redis_task" {
  template = "${file("${path.module}/redis.json.tpl")}"
  vars {
    redis_docker_image = "${var.redis_docker_image}"
  }
}

resource "aws_ecs_service" "redis" {
  name            = "redis"
  cluster         = "${var.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.redis.arn}"
  desired_count   = 1
  # depends_on      = ["aws_iam_role_policy.ecs_service_role_policy"]
}

resource "aws_ecs_task_definition" "redis" {
  family                = "redis"
  container_definitions = "${template_file.redis_task.rendered}"
}

# https://github.com/adamdecaf/ecs-cluster/commit/259ea785f7a1b6d555b7769be83f774b59e0fc00
