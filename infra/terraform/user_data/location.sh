#!/bin/bash

cd /home/ec2-user/ && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip /home/ec2-user/awscliv2.zip
/home/ec2-user/./aws/install

SECRET_JSON=$(aws secretsmanager get-secret-value --region us-east-1 --secret-id DataDog --query SecretString --output text)

DataDog=$(echo "$SECRET_JSON" | jq -r .DataDog)

# Create Docker network if not exists
docker network create datadog-network

# Run Datadog Agent FIRST
docker run -d --name datadog-agent \
  --network datadog-network \
  --cgroupns host \
  --pid host \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /proc/:/host/proc/:ro \
  -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
  -v /var/run/datadog/:/var/run/datadog/ \
  -e DD_API_KEY="$DataDog" \
  -e DD_SITE="us5.datadoghq.com" \
  -e DD_LOGS_ENABLED=true \
  -e DD_APM_ENABLED=true \
  -e DD_APM_NON_LOCAL_TRAFFIC=true \
  -e DD_APM_RECEIVER_SOCKET=/var/run/datadog/apm.socket \
  gcr.io/datadoghq/agent:7

docker run -d -p 8080:8080 --name locationsmicroservice \
  --network datadog-network \
  -e DATADOG_API_KEY="$DataDog" \
  -e DD_TRACE_AGENT_URL=unix:///var/run/datadog/apm.socket \
  -v /var/run/datadog/:/var/run/datadog/ \
  tommyquatretempspxl/locationsmicroservice