#!/bin/bash

AMI=ami-0f3c7d07486cad139
SG_ID=sg-03edb3d1f2077ba07
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

for i in "${INSTANCES[@]}"
do
    echo "Instance is: $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi
   
    aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type $INSTANCE_TYPE --security-group-ids sg-03edb3d1f2077ba07 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"
done

