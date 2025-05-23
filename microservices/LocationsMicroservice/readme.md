# The SDK will automatically look for credentials in this order:

## 1. Environment Variables:

   * `AWS_ACCESS_KEY_ID`

   * `AWS_SECRET_ACCESS_KEY`

   * `AWS_REGION` (or `AWS_DEFAULT_REGION`)

##  2. System Properties:
~~~bash
-Daws.accessKeyId=your-access-key
-Daws.secretAccessKey=your-secret-key
-Daws.region=your-region
~~~

## 3. AWS Profile (~/.aws/credentials): File: `~/.aws/credentials`
~~~bash
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
~~~
File: `~/.aws/config`

~~~bash
[default]
region = eu-west-1
~~~

## 4. IAM Role (if deployed on EC2, ECS, Lambda) — it automatically picks up the instance role.