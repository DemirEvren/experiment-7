import os
import pymysql
import requests
import json
import boto3
import time
from datetime import datetime

# RDS Configuration
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_NAME = 'mysql'

# Datadog API Configuration
DATADOG_API_KEY = os.environ['DATADOG_API_KEY']
DATADOG_LOG_URL = "https://http-intake.logs.us5.datadoghq.com/v1/input"

# Parameter Store Configuration
SSM_CLIENT = boto3.client('ssm')
LAST_TIMESTAMP_PARAM = '/rds/last_error_log_timestamp'

# Self-Trigger Lambda Client
LAMBDA_CLIENT = boto3.client('lambda')

def get_last_timestamp():
    try:
        response = SSM_CLIENT.get_parameter(Name=LAST_TIMESTAMP_PARAM)
        return response['Parameter']['Value']
    except SSM_CLIENT.exceptions.ParameterNotFound:
        print("ℹ️ No previous timestamp found. Defaulting to 2025-03-20 00:00:00")
        return "2025-03-20 00:00:00"

def save_last_timestamp(timestamp):
    SSM_CLIENT.put_parameter(
        Name=LAST_TIMESTAMP_PARAM,
        Value=timestamp,
        Type='String',
        Overwrite=True
    )

def retry_with_backoff(func, max_retries=3, delay=5):
    """Retries a function with exponential backoff for reliability."""
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            print(f"❌ Error (Attempt {attempt + 1}): {e}")
            time.sleep(delay * (2 ** attempt))
    raise Exception("❌ All retries failed.")

def self_invoke(context):
    """Re-invoke this Lambda function with a delay."""
    print("⏳ Waiting 5 minutes before re-triggering Lambda...")
    time.sleep(300)  # 300 seconds = 5 minutes
    print("🔄 Re-invoking Lambda for next cycle...")
    LAMBDA_CLIENT.invoke(
        FunctionName=context.function_name,
        InvocationType='Event'
    )

def lambda_handler(event, context):
    print("✅ Starting Lambda Execution...")

    # Step 1: Connect to RDS
    try:
        print("✅ Connecting to RDS...")
        connection = retry_with_backoff(lambda: pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        ))
        print("✅ Connected to RDS successfully.")
    except Exception as e:
        print(f"❌ Error connecting to RDS: {e}")
        return {"status": "error", "error": str(e)}

    # Step 2: Query RDS Error Logs with Improved Filtering
    last_timestamp = get_last_timestamp()
    print(f"🕒 Last saved timestamp: {last_timestamp}")

    try:
        print(f"✅ Fetching logs since: {last_timestamp}")
        with connection.cursor() as cursor:
            cursor.execute(f"""
                SELECT event_time, user_host, argument 
                FROM general_log 
                WHERE event_time > '{last_timestamp}' 
                AND argument REGEXP 'syntax|denied|unknown|failed|error|disconnect|timeout'
                ORDER BY event_time DESC;
            """)
            logs = cursor.fetchall()

        for log in logs:
            if isinstance(log['event_time'], datetime):
                log['event_time'] = log['event_time'].strftime('%Y-%m-%d %H:%M:%S')
            if isinstance(log['argument'], bytes):
                log['argument'] = log['argument'].decode('utf-8', errors='replace')

        print(f"✅ Retrieved {len(logs)} new log entries.")
    except Exception as e:
        print(f"❌ Error querying logs: {e}")
        return {"status": "error", "error": str(e)}
    finally:
        connection.close()

    if logs:
        latest_timestamp = logs[0]['event_time']
        save_last_timestamp(latest_timestamp)

        # Step 3: Send Logs to Datadog
        try:
            print("✅ Sending logs to Datadog...")
            payload = [
                {
                    "ddsource": "mysql",
                    "service": "rds-error-log",
                    "hostname": DB_HOST,
                    "status": "error",
                    "message": json.dumps(log)
                }
                for log in logs
            ]

            headers = {
                "Content-Type": "application/json",
                "DD-API-KEY": DATADOG_API_KEY
            }

            response = requests.post(DATADOG_LOG_URL, headers=headers, json=payload)

            if response.status_code == 200:
                print("✅ Logs successfully sent to Datadog.")
            else:
                print(f"❌ Failed to send logs. Status Code: {response.status_code}")
                print(f"Response Body: {response.text}")
        except Exception as e:
            print(f"❌ Error sending logs to Datadog: {e}")
            return {"status": "error", "error": str(e)}
    else:
        print("✅ No new logs to send.")

    # Step 4: Self-Invoke to Run Again
    self_invoke(context)

    return {"status": "success"}
