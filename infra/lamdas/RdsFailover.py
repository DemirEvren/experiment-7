import boto3
import time

rds_client = boto3.client('rds')

def lambda_handler(event, context):
    primary_db = "todomysqldb"
    replica_db = "todomysqldb-replica"

    # Check the primary RDS instance status
    primary_status = rds_client.describe_db_instances(DBInstanceIdentifier=primary_db)['DBInstances'][0]['DBInstanceStatus']

    if primary_status != 'available':
        print(f"Primary database {primary_db} is down. Promoting Read Replica...")
        rds_client.promote_read_replica(DBInstanceIdentifier=replica_db)
        print(f"Read Replica {replica_db} promoted successfully.")
