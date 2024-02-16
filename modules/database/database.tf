resource "aws_db_subnet_group" "Cloud-DBSubnetGroup" {
  name = "cloud-db-subnet-group"
  subnet_ids = [
    var.cloud_private_subnets[0].id,
    var.cloud_private_subnets[1].id
  ]
  tags = {
    Name = "AWSCloud-DBSubnetGroup"
    Project = "Demo"
  }
}

resource "aws_security_group" "cloudDBSecurityGroup" {
  name = "cloud-db-security-group"
  vpc_id = var.cloud_vpc_id
  tags = {
  Name ="AWSCloud-DBSecurityGroup"
  Project = "Demo"
  }

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [
        var.cloud_private_subnet_cidrs[0],
        var.cloud_private_subnet_cidrs[1]
    ]
  }
}

resource "aws_db_instance" "cloudrds" {
  //availability_zone = var.db_az
  multi_az               = true
  db_subnet_group_name = aws_db_subnet_group.Cloud-DBSubnetGroup.name
  vpc_security_group_ids = [ aws_security_group.cloudDBSecurityGroup.id]
  allocated_storage = 20
  storage_type = "standard"
  engine = "postgres"
  engine_version = "12"
  instance_class = "db.t3.micro"
  backup_retention_period = 7  # Set the backup retention period for the primary RDS instance
  name = var.db_name
   username = var.db_user_name
   password = var.db_user_password
   skip_final_snapshot = true
   identifier                = "awscloud-rds-instance"
   tags = {
    Name = "AWSCloud_RDS"
   }

}

# Existing resources (aws_db_subnet_group, aws_security_group, aws_db_instance)

# Define a read replica
resource "aws_db_instance" "read_replica" {
  depends_on                 = [aws_db_instance.cloudrds]
  replicate_source_db         = aws_db_instance.cloudrds.id
  instance_class             = "db.t3.micro"
  engine                     = aws_db_instance.cloudrds.engine
  allocated_storage          = aws_db_instance.cloudrds.allocated_storage
  storage_type               = aws_db_instance.cloudrds.storage_type
  skip_final_snapshot = true
  availability_zone      = "us-east-1c"  # Specify the desired region's availability zone
  //backup_retention_period = 7 
  identifier                = "awscloud-rds-replica"
  tags = {
    //Name    = "ReadReplica-${var.db_name}"
    Name = "AWSCloud_Replica"
    Project = "Demo"
  }
}



# Output the connection details for the instances
output "primary_db_endpoint" {
  value = aws_db_instance.cloudrds.endpoint
}

output "read_replica_db_endpoint" {             
  value = aws_db_instance.read_replica.endpoint
}

/*output "dr_db_endpoint" {
  value = aws_db_instance.dr_instance.endpoint
}*/

