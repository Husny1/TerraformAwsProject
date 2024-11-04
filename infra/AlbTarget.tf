// target groups for the app instances
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "app_target_group" {
  name     = "ALB-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "App Target Group"
  }
}

// listener for the load balancer
// https://spacelift.io/blog/terraform-alb
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.LoadBalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

// target instance A which is app cont 1 
resource "aws_lb_target_group_attachment" "app_instance_a" {
  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id        = aws_instance.instance_a.id
  port             = 80
}

// target instance B which is app cont 2
resource "aws_lb_target_group_attachment" "app_instance_b" {
  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id        = aws_instance.instance_b.id
  port             = 80
}


