#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-051b1f8e584ea35b8"


for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.micro --security-group-ids sg-051b1f8e584ea35b8 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    if [ $instance != "fronend" ]; then
        Ip=$(aws ec2 describe-instances --instance-id $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
        Ip=$(aws ec2 describe-instances --instance-id $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi

    echo "$instance:$Ip"

    

done