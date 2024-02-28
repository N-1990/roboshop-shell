#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-TIMESTAMP.log"

MONGODB_HOST=mongodb.tsoftsolution.online

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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "nodejs disable"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "nodejs enable "

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "nodejs installing"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user alreaday exist .. $Y SKIP $N"
fi

mkdir -p /app  &>> $LOGFILE

VALIDATE $? " creating app directery"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "downloding user application"

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzip user application"

npm install  &>> $LOGFILE

VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service 

VALIDATE $? "coping user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "start user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y  &>> $LOGFILE

VALIDATE $? "installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE

VALIDATE $? "loding user data into mongodb"