# The following enables access to the IP address of the EC2 instance
# once the instance has been provisioned.
output "instance_ip_addr" {
  value = aws_instance.instance.private_ip
}

# The following enables access to the IP address of the DB instance
# once the instance has been provisioned.
output "db_instance_addr" {
  value = aws_db_instance.db_instance.address
}
