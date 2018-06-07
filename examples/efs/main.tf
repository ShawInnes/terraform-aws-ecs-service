//
// EFS setup
//
module "efs_service_1" {
  source       = "devops-workflow/efs/aws"
  version      = "0.6.1"
  name         = "service-1"
  attributes   = ["efs"]
  environment  = "${var.environment}"
  region       = "${var.region}"
  vpc_id       = "${data.aws_vpc.vpc.id}"
  subnets      = "${data.aws_subnet_ids.private_subnet_ids.ids}"
  ingress_cidr = "${data.aws_subnet.private_subnets.*.cidr_block}"
}

module "efs_service_2" {
  source       = "devops-workflow/efs/aws"
  version      = "0.6.1"
  name         = "service-2"
  attributes   = ["efs"]
  environment  = "${var.environment}"
  region       = "${var.region}"
  vpc_id       = "${data.aws_vpc.vpc.id}"
  subnets      = "${data.aws_subnet_ids.private_subnet_ids.ids}"
  ingress_cidr = "${data.aws_subnet.private_subnets.*.cidr_block}"
}

//
// ECS cluster setup
//
data "template_file" "extra_user_data" {
  template = "${file("${path.module}/templates/userdata-nfs.sh")}"

  vars {
    mounts = "${module.efs_service_1.dns_name}:${module.efs_service_1.name} ${module.efs_service_2.dns_name}:${module.efs_service_2.name}"
  }
}

module "ecs-cluster" {
  source                      = "git::https://github.com/devops-workflow/terraform-aws-ecs-cluster.git"
  name                        = "ecs-1"
  environment                 = "${var.environment}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  min_servers                 = "2"
  servers                     = "2"
  subnet_id                   = ["${data.aws_subnet_ids.private_subnet_ids.ids}"]
  vpc_id                      = "${data.aws_vpc.vpc.id}"
  additional_user_data_script = "${data.template_file.extra_user_data.rendered}"
}

# Add ECS Cluster SG to EFS security groups
resource "aws_security_group_rule" "ecs-cluster-efs-service-1" {
  description              = "ECS Cluster"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = "${module.efs_service_1.security_group}"
  source_security_group_id = "${module.ecs-cluster.cluster_security_group_id}"
}

resource "aws_security_group_rule" "ecs-cluster-efs-service-2" {
  description              = "ECS Cluster"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = "${module.efs_service_2.security_group}"
  source_security_group_id = "${module.ecs-cluster.cluster_security_group_id}"
}

//
// ECS Services
//
module "basic" {
  source                = "../../"
  name                  = "basic"
  ecs_cluster_arn       = "${module.ecs-cluster.cluster_id}"
  ecs_security_group_id = "${module.ecs-cluster.cluster_security_group_id}"
  environment           = "${var.environment}"
  organization          = "wiser"

  #docker_registry = "105667981759.dkr.ecr.us-west-2.amazonaws.com/wiser"
  #docker_image    = "map-application:latest"
  docker_image = "infrastructureascode/hello-world:latest"

  app_port       = 8080                                              # target group & container port
  lb_enable_http = true
  lb_internal    = true
  lb_subnet_ids  = ["${data.aws_subnet_ids.private_subnet_ids.ids}"]
  region         = "${var.region}"
  vpc_id         = "${data.aws_vpc.vpc.id}"

  docker_port_mappings = "${list(
    map("containerPort", 8080, "hostPort", 8080, "protocol", "tcp")
    )}"

  docker_mount_points = "${list(
    map("containerPath", "/mnt/efs", "sourceVolume", "efs")
    )}"

  docker_volumes = "${list(
    map("name", "efs", "host_path", "/mnt/efs/${module.efs_service_1.name}")
    )}"
}

module "basic_2" {
  source                = "../../"
  name                  = "basic-2"
  ecs_cluster_arn       = "${module.ecs-cluster.cluster_id}"
  ecs_security_group_id = "${module.ecs-cluster.cluster_security_group_id}"
  environment           = "${var.environment}"
  organization          = "wiser"

  #docker_registry = "105667981759.dkr.ecr.us-west-2.amazonaws.com/wiser"
  #docker_image    = "map-application:latest"
  docker_image = "infrastructureascode/hello-world:latest"

  app_port       = 8080                                              # target group & container port
  lb_enable_http = true
  lb_internal    = true
  lb_subnet_ids  = ["${data.aws_subnet_ids.private_subnet_ids.ids}"]
  region         = "${var.region}"
  vpc_id         = "${data.aws_vpc.vpc.id}"

  docker_port_mappings = "${list(
    map("containerPort", 8080, "hostPort", 8080, "protocol", "tcp")
    )}"

  docker_mount_points = "${list(
    map("containerPath", "/mnt/efs", "sourceVolume", "efs")
    )}"

  docker_volumes = "${list(
    map("name", "efs", "host_path", "/mnt/efs/${module.efs_service_2.name}")
    )}"
}
