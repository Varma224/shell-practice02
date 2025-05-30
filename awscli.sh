#!/bin/bash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0c83d4f49209ee12d"
ZONE_ID="Z053279234NT99R7HQSG4"
DOMAIN_NAME="deeps.sbs"
INSTANCES=("frontend" "redis" "mongodb" "cart" "shipping" "catalogue" "user" "mysql" "rabbitmq" "payment" "dispatch")

for instance in ${INSTANCES[@]}; do
  INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-0c83d4f49209ee12d --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)

  if [ $instance != "frontend" ]; then
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
  else
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
  fi
  echo "$instance Ip address is $IP"

  aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
  {
       "Comment": "Creating or updating a record", 
       "Changes": [{
       "Action" : "UPSERT",
       "ResourceRecordSet" : {
       "Name" : "'$instance'.'$DOMAIN_NAME'",
       "Type" : "A",
       "TTL"  : 1,
       "ResourceRecords" : [{
       "Value" : "'$IP'"
       }]
  }
  }]
  }'

done
