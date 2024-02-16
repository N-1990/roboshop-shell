#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script statted executing at $TIMESTAMP"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .. $R FAILED $N"
        exit 1
    else
        echo -e "$2 .. $G SUCCESS $N"
    fi 
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run the script with root user access $N" 
    exit 1
else
    echo "you are in root user"
fi

dnf install maven -y &>> $LOGFILE

VALIDATE $? "installing maven"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip  &>> $LOGFILE

VALIDATE $? "downloding shipping"

cd /app

unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "unzip shipping"

mvn clean package &>> $LOGFILE

VALIDATE $? "installing dependencies"

mv target/shipping-1.0.jar shipping.jar  &>> $LOGFILE

VALIDATE $? "renaming jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "copying shipping service "

systemctl daemon-reload  &>> $LOGFILE

VALIDATE $? "daemon reload shipping"

systemctl enable shipping  &>> $LOGFILE

VALIDATE $? "enabling shipping"

systemctl start shipping  &>> $LOGFILE

VALIDATE $? "starting shipping"

dnf install mysql -y  &>> $LOGFILE

VALIDATE $? "installing mysql client"

mysql -h mysql.tsoftsolution.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOGFILE

VALIDATE $? "loading shipping data"

systemctl restart shipping  &>> $LOGFILE

VALIDATE $? "restart shipping"