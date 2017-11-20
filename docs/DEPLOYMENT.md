# Deployment

## AWS Elastic Beanstalk

### Set up a VPC

[Set up a VPC with public and private subnets](https://github.com/somleng/twilreapi/blob/master/docs/AWS_VPC_SETUP.md).

### Create a Bastion Host for debugging (optional)

In this guide we will setup your environment so that the EC2 instances are deployed to the private subnets, similar to what is shown in [this diagram](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenario2.html). Our private subnets, created in the previous step, do not have an Internet Gateway attached to the routing table and therefore cannot be accessed from the Internet. Therefore, in order to have SSH access to our EC2 instances (for debugging purposes) we need to create a bastion host. In order to create a bastion host, launch a new nano instance in one of your public subnets and assign it an elastic IP. SSH into the bastion host with the `-A` flag. For example `$ ssh -A ubuntu@elastic-ip`. From the bastion host you should be able to ssh into your Elastic Beanstalk SSH instances via the private IP.

### Create a new a RDS Postgresql Database

Follow [this guide](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/AWSHowTo.RDS.html?icmpid=docs_elasticbeanstalk_console) to setup a new RDS Postgresql Instance. Note down the RDS instance's security group id.

### Create a new web application environment

As described above, we will setup your environment so that the EC2 instances are deployed to the private subnets in your VPC.

Launch a new web application environment using the ruby (Puma) platform. When prompted for the VPC, enter the VPC you created above. When prompted if you want to associate a public IP Address select No. When prompted for EC2 subnets, enter your *private* subnets. When prompted for your ELB subnets enter your *public* subnets. When prompted for Security Groups enter the id of the RDS Instance's security group.

Modify the commands below to match your details:

```
$ eb platform select --profile <profile-name>
$ eb create somleng-scfm-web --vpc -r <region> --envvars DATABASE_URL=postgres://dbuser:dbpassword@dbendpoint:dbport/db_name,SECRET_KEY_BASE=`bundle exec rails secret`,RAILS_MAX_THREADS=32,AWS_REGION=aws-region-id,ACTIVE_JOB_ADAPTER=active_elastic_job --profile <profile-name>
```

#### Environment Variables

Configure the following Environment Variables using `eb setenv` or the Elastic Beanstalk Web Console.

Required:

```
SECRET_KEY_BASE=`bundle exec rails secret`
DATABASE_URL=postgres://dbuser:dbpassword@dbendpoint:dbport/db_name
RAILS_MAX_THREADS=32 # Default used by Elasic Beanstalk's Puma Configuration
AWS_REGION=aws-region-id
ACTIVE_JOB_ADAPTER=active_elastic_job
ACTIVE_JOB_QUEUE_NAME=name-of-sqs-queue
SOMLENG_ACCOUNT_SID=somleng-account-sid
SOMLENG_AUTH_TOKEN=somleng-auth-token
SOMLENG_CLIENT_REST_API_HOST=somleng-rest-api-host
SOMLENG_CLIENT_REST_API_BASE_URL=somleng-rest-api-base-url
TWILIO_ACCOUNT_SID=twilio-account-sid
TWILIO_AUTH_TOKEN=twilio-auth-token
PLATFORM_PROVIDER=twilio-or-somleng
```

Optional but highly recommended:

```
FORCE_SSL=1 # Forces SSL (you'll need a SSL certificate)
HTTP_BASIC_AUTH_USER=api-key # Specify a HTTP Basic Auth User to authenticate API access
```

Optional:

```
HTTP_BASIC_AUTH_PASSWORD=secret # Specify a HTTP Basic Auth Password to authenticate API access
```

### Create a new worker environment

Create a worker environment(s) for processing background jobs such as queuing remote calls, fetching remote calls and running batch operations.

Launch a new worker environment using the ruby (Puma) platform. When prompted for the VPC, enter the VPC you created above. When prompted for EC2 subnets, enter the *private* subnets (separated by a comma for both availability zones). Enter the same for your ELB subnets (note there is no ELB for Worker environments so this setting will be ignored).

$ eb create somleng-scfm-worker1 --vpc --tier worker -i t2.nano --envvars DATABASE_URL=postgres://dbuser:dbpassword@dbendpoint:dbport/db_name,SECRET_KEY_BASE=same-as-above,RAILS_MAX_THREADS=32,PROCESS_ACTIVE_ELASTIC_JOBS=true,AWS_REGION=aws-region-id,ACTIVE_JOB_ADAPTER=active_elastic_job --profile <profile-name>

You can optionally repeat this step if you want to create separate workers for separate jobs.

#### Environment Variables

Configure the following Environment Variables using `eb setenv` or the Elastic Beanstalk Web Console.

Required:

```
SECRET_KEY_BASE=same-as-web-environment
DATABASE_URL=postgres://dbuser:dbpassword@dbendpoint:dbport/db_name
RAILS_MAX_THREADS=32
PROCESS_ACTIVE_ELASTIC_JOBS=true
AWS_REGION=aws-region-id
ACTIVE_JOB_ADAPTER=active_elastic_job
ACTIVE_JOB_QUEUE_NAME=name-of-sqs-queue
SOMLENG_ACCOUNT_SID=somleng-account-sid
SOMLENG_AUTH_TOKEN=somleng-auth-token
SOMLENG_CLIENT_REST_API_HOST=somleng-rest-api-host
SOMLENG_CLIENT_REST_API_BASE_URL=somleng-rest-api-base-url
TWILIO_ACCOUNT_SID=twilio-account-sid
TWILIO_AUTH_TOKEN=twilio-auth-token
PLATFORM_PROVIDER=twilio-or-somleng
```

Optional:

Override default configuration by configuring additional workers/queues:

```
ACTIVE_JOB_QUEUE_REMOTE_CALL_JOB_QUEUE_NAME=sqs-queue-name
ACTIVE_JOB_FETCH_REMOTE_CALL_JOB_QUEUE_NAME=sqs-queue-name
ACTIVE_JOB_RUN_BATCH_OPERATION_JOB_QUEUE_NAME=sqs-queue-name
```

Follow the [active-elastic-job README](https://github.com/tawan/active-elastic-job) for more info on configuring Active Elastic Job.

#### Worker Auto Scaling

1. Create two CloudWatch alarms for each SQS queue using the AWS CloudWatch console using the metric `ApproximateNumberOfMessagesVisible`. One alarm should be for scaling up, and the other for scaling down.
2. Attach the alarm to the AutoScaling group which was created by Elastic Beanstalk for the worker environment. Check the tag names of the Autoscaling group to confirm.
3. Optionally set the minimum instance count to 0 in the environment settings for Elastic Beanstalk.
