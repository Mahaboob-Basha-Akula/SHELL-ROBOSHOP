#/bin/bash


AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0cb74036ffa409ec3"
ZONE_ID="Z079516023DG9ZEN0RSC9"
DOMAIN_NAME="learnwithmahaboob.cyou"

for instances in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro        --security-group-ids $SG_ID --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instances}]' --query 'Instances[0].InstanceId' --output text)

    if [ $INSTANCE_ID = frontend ]; then
        INSTANCE_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        RECORD_NAME=$DOMAIN_NAME
    else
        INSTANCE_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        RECORD_NAME=$instances.$DOMAIN_NAME
    fi
    echo "$instances: $INSTANCE_IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '{
        "Comment": "Updating A record",
        "Changes": [{
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [{ 
                    "Value" : "'$INSTANCE_IP'" 
                    }]
            }
        }]
    }'
done

