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

useradd roboshop &>> $LOGFILE

VALIDATE $? "roboshop user adding"

mkdir /app  &>> $LOGFILE

VALIDATE $? " creating app directery"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>> $LOGFILE

VALIDATE $? "downlode the cartalogue application"

cd /app 

VALIDATE $? " change app directery"

unzip /tmp/catalogue.zip  &>> $LOGFILE

VALIDATE $? "unzip catalogue application"

npm install &>> $LOGFILE

VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service  &>> $LOGFILE

VALIDATE $? "coping catalogue.service file "

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reload catalogue"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo  &>> $LOGFILE

VALIDATE $? "coping mongorepo"

dnf install mongodb-org-shell -y  &>> $LOGFILE

VALIDATE $? "installing mongodb org shell"

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "loding mongodb data in to catalogue "