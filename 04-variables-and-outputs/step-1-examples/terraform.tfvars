instance_name = "ec2-instance-hello-world-1"

ami           = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1

instance_type = "t2.micro"

# NB:
# We don't specify a value for the password in here,
# because that is a piece of sensitive information.
# It is going to be passed in a different way.
