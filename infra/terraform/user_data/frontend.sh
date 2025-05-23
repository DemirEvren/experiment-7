#!/bin/bash

yum update -y

cd /home/ec2-user/ && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip /home/ec2-user/awscliv2.zip
/home/ec2-user/./aws/install

SECRET_JSON=$(aws secretsmanager get-secret-value --region us-east-1 --secret-id DataDog --query SecretString --output text)

DataDog=$(echo $SECRET_JSON | jq -r .DataDog)



# Run frontend container with Datadog log label
docker run -d -p 80:80 --name todoapp-frontend \
  --label com.datadoghq.ad.logs='[{"source": "nginx", "service": "todoapp-frontend"}]' \
  tommyquatretempspxl/todoappfrontend:nvrg

# Run Datadog agent with log collection enabled
docker run -d --cgroupns host --pid host --name datadog-agent \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /proc/:/host/proc/:ro \
  -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
  -e DD_API_KEY=$DataDog \
  -e DD_SITE="us5.datadoghq.com" \
  -e DD_LOGS_ENABLED=true \
  -e DD_APM_ENABLED=true \
  gcr.io/datadoghq/agent:7