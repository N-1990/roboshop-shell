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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "installing python"

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "downloding payment app"

cd /app &>> $LOGFILE

unzip -o /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "unzip payment"

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "copying payment service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reload"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "enabling payment"

systemctl start payment &>> $LOGFILE

VALIDATE $? "start payment"