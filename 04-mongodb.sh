#!/bin/bash

N="\e[0m"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
P="\e[35m"

USER_ID=$(id -u)

LOG_FOLDER="/var/log/shell-roboshop/"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

if [ $USER_ID -ne 0 ]; then
    echo -e "$R ERROR:: Need root privilages $N "
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne  0 ]; then
        echo -e " Installation of $2 $R Failed $N"
        exit  1
    else
        echo -e " Installation of $2 $G Success $N"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Adding mongo repo"




dnf list installed mongodb-org -y &>>$LOG_FILE
if [ $? -ne 0 ]; then 
    dnf install mongodb-org -y &>>$LOG_FILE
    VALIDATE $? "mongodb"
else 
    echo -e "$G $2 is already exists... $N $Y SKIPPING $N "
fi


systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling mongodb"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections to MongoDB"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarted MongoDB"

