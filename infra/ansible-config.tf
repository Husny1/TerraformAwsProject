
// creates inventory1.yml to get host ip and dns 
// can use these details to access instance 
resource "local_file" "ansible_inventory1" {
  filename = "${path.module}/inventory1.yml"
  content  = <<-EOF
    all_servers:
      hosts:
        ${aws_instance.servers.public_dns}:
          ansible_host: ${aws_instance.servers.public_ip}
  EOF
}


// creates inventory2.yml to get host ip and dns  for the 3 instances relating to section B
// can use these details to access instance in playbook
// seperating instances by hosts to define container specific apps

resource "local_file" "ansible_inventory2" {
  filename = "${path.module}/inventory2.yml"
  content  = <<-EOF
    AppContainer:
      hosts:
        ${aws_instance.instance_a.public_dns}:
          ansible_host: ${aws_instance.instance_a.public_ip}
        ${aws_instance.instance_b.public_dns}:
          ansible_host: ${aws_instance.instance_b.public_ip}

    DBContainer:
      hosts:
        ${aws_instance.instance_c.public_dns}:
          ansible_host: ${aws_instance.instance_c.public_ip}
          ansible_private_ip: ${aws_instance.instance_c.private_ip}


    all_servers:
      children:
        DBContainer:
        AppContainer:

  EOF
}
