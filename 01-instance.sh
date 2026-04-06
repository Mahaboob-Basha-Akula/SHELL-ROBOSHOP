#/bin/bash


AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-051b1f8e584ea35b8"

for instance in $@
do
    Instance_Id = $(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro  --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,value=$instance}]" --query 'Instance[0].InstanceId' --output text)

    if [ $instance = frontend ]; then 
        IpAddress=$(aws ec2 describe instances --instance_id $Instance_Id --query "Reservations[0].Instances[0].PublicIpAddress" --outpu text)
    else
        IpAddress=$(aws ec2 describe instances --instance_id $Instance_Id --query "Reservations[0].Instances[0].PrivateIpAddress" --outpu text)

    fi
    echo "$instance: $IpAddress"
done

