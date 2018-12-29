
resource "aws_security_group" "bastion_asg_sg" {
  name = "bastion-asg-sg-${var.name}-${var.environment}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.bastion_allowed_admin_cidrs}"]
  }

  vpc_id                  = "${var.bastion_vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "bastion_instance_profile"
  role = "${aws_iam_role.bastion_role.name}"
}

resource "aws_iam_role" "bastion_role" {
  name = "bastion_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_launch_configuration" "bastion_lc" {
  name_prefix                    = "bastion-asg-${var.name}-${var.environment}-"
  enable_monitoring       = true
  iam_instance_profile    = "${aws_iam_instance_profile.bastion_instance_profile.id}"
  image_id                = "${var.bastion_host_ami}"
  instance_type           = "${var.bastion_instance_type}"
  key_name                = "${var.bastion_keyname}"
  security_groups         = ["${aws_security_group.bastion_asg_sg.id}"]



}

resource "aws_autoscaling_group" "bastion_asg" {
  name                    = "bastion-asg-${var.name}-${var.environment}"

  health_check_type       = "EC2"
  launch_configuration    = "${aws_launch_configuration.bastion_lc.name}"

  max_size                = "${var.bastion_asg_max_size}"
  min_size                = "${var.bastion_asg_min_size}"

  target_group_arns       = ["${aws_lb_target_group.bastion_nlb_tg.id}"]

  vpc_zone_identifier     = ["${var.bastion_asg_subnets}"]

  tag {
    key                   = "Environment"
    value                 = "${var.environment}"
    propagate_at_launch   = true
  }

  tag {
    key                   = "Name"
    value                 = "bastion-asg-${var.name}-${var.environment}"
    propagate_at_launch   = true
  }

}

resource "aws_lb" "bastion_nlb" {
  name                    = "bastion-nlb-${var.name}-${var.environment}"
  enable_cross_zone_load_balancing = "true"
  internal                = "${var.bastion_nlb_internal}"
  load_balancer_type      = "network"

  subnets                 = ["${var.bastion_nlb_subnets}"]

  tags = {
    Environment           = "${var.environment}"
    Automation            = "Terraform"
  }
}

resource "aws_lb_listener" "bastion_nlb_listener" {
  load_balancer_arn       = "${aws_lb.bastion_nlb.id}"
  port                    = "22"
  protocol                = "TCP"

  default_action {
    target_group_arn      = "${aws_lb_target_group.bastion_nlb_tg.id}"
    type                  = "forward"
  }
}

resource "aws_lb_target_group" "bastion_nlb_tg" {
  name                    = "bastion-nlb-tgt-${var.environment}-${var.name}"
  health_check {
      protocol = "TCP"
      port     = "22"
  }

  port                    = "22"
  protocol                = "TCP"
  vpc_id                  = "${var.bastion_vpc_id}"

  depends_on = ["aws_lb.bastion_nlb"]

  tags = {
    Environment           = "${var.environment}"
    Automation            = "Terraform"
  }
}
