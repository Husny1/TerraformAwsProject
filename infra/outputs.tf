// output for section A ip and dns main ec2 ip/dns info
output "vm_public_hostname" {
value = aws_instance.servers.public_dns
}

output "vm_public_ip" {
  value = aws_instance.servers.public_ip
}

// Section B outputs with Load balancer
output "ec2_instances" {
  value = {
    instanceA_publicDNS = aws_instance.instance_a.public_dns
    instanceA_privateIp = aws_instance.instance_a.private_ip
    instanceA_publicIp  = aws_instance.instance_a.public_ip

    instanceB_publicDNS = aws_instance.instance_b.public_dns
    instanceB_privateIp = aws_instance.instance_b.private_ip
    instanceB_publicIp  = aws_instance.instance_b.public_ip

    instanceC_publicDNS = aws_instance.instance_c.public_dns
    instanceC_privateIp = aws_instance.instance_c.private_ip
    instanceC_publicIp  = aws_instance.instance_c.public_ip
  }
}

// load bal dns 
output "load_balancer_dns" {
  value = aws_lb.LoadBalancer.dns_name
}

