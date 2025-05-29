#!/bin/bash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0c83d4f49209ee12d"
ZONE_ID="Z053279234NT99R7HQSG4"
DOMAIN_NAME="deeps.sbs"
INSTANCES=("frontend" "redis" "mongodb" "cart" "shipping" "catalogue" "user" "mysql" "rabbitmq" "payment" "dispatch")

for instance in ${INSTANCES[@]}; do
  INSTANCE_ID=$(
    aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-0c83d4f49209ee12d
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]"
    --query "Instances[0].InstanceID" --output text
  )

  if [ $instance != "frontend" ]; then
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "$instance.PrivateIpAddress" --output text)
  else
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "$instance.PublicIpAddress" --output text)
  fi
  echo "$instance Ip address is $IP"
done
