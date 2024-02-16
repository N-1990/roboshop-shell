#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-TIMESTAMP.log"
exec &>$LOGFILE

echo "script stated executing at $TIMESTAMP"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N "
    fi
}

if [ $ID -ne 0 ]
then
    echo -e " $R ERROR:: Please run the script with root user access $N"
    exit 1
else
    echo "you are in root user"
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y 

VALIDATE $? "installing remi release"

dnf module enable redis:remi-6.2 -y 

VALIDATE $? "enabling redis"

dnf install redis -y 

VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf

VALIDATE $? "allowing remote connection"

systemctl enable redis  

VALIDATE $? "enabling redis"

systemctl start redis 

VALIDATE $? "starting redis"