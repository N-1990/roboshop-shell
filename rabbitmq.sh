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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "downloding erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash  &>> $LOGFILE

VALIDATE $? "downloding rabbitmq script"

dnf install rabbitmq-server -y  &>> $LOGFILE

VALIDATE $? "installing rabbitmq script"

systemctl enable rabbitmq-server &>> $LOGFILE

VALIDATE $? "enabling rabbitmq server"

systemctl start rabbitmq-server &>> $LOGFILE

VALIDATE $? "start rabbitmq server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE

VALIDATE $? "creating user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE

VALIDATE $? "setting permission"