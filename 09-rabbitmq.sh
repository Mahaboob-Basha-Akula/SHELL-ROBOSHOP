#!/bin/bash

N="\e[0m"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
P="\e[35m"



LOG_FOLDER="/var/log/rabbitmq-shell"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo -e "$R ERROR:: Need root privilages $N"
    exit 1
fi
mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $? -ne 0 ]; then 
        echo -e " $R Package install is FAILED $N"
    else 
        echo -e "$G Package install is SUCCESS $N"
    fi
}



cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Rabbitmq installation"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling rabbitmq"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Rabbitmq Started"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
VALIDATE $? "Adding new user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Settimmg permissions to roboshop user"

