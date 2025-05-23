#!/usr/bin/env python3

import boto3
import json
import sys
from botocore.exceptions import ClientError

def get_secret():
    secret_name = "terraformCreds"
    region_name = "us-east-1"

    session = boto3.session.Session()
    client = session.client("secretsmanager", region_name=region_name)

    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(response['SecretString'])

        # Output in the format expected by Terraform external data source
        print(json.dumps({
            "aws_access_key_id": secret["aws_access_key_id"],
            "aws_secret_access_key": secret["aws_secret_access_key"],
            "token": secret.get("token", "")  # Optional if token is not always used
        }))
    except ClientError as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)

if __name__ == "__main__":
    get_secret()
