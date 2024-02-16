#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-TIMESTAMP.log"

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

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "downloding cart application "

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "unzip cart application"

npm install &>> $LOGFILE

VALIDATE $? "installig dependencies "

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service

VALIDATE $? "coping cart service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reload cart"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "eabling cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "starting cart"