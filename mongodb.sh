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
    else
        echo -e "$2 .. $R SUCCESS $N"
    fi 
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run the script with root user access $N" 
    exit 1
else
    echo "you are in root user"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "mongo repo copied"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "mongodb installing"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "mongodb enabling"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "mongodb starting"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Remote access to mongodb"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "restating mongodb"