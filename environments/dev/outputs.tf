# environments/dev/outputs.tf

output "alb_dns_east" {
  value = module.web_east_alb.alb_dns
}

output "alb_dns_west" {
  value = module.web_west_alb.alb_dns
}

output "asg_name_east" {
  value = module.web_east_compute.asg_name
}

output "asg_name_west" {
  value = module.web_west_compute.asg_name
}
