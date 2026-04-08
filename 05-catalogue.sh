#!/bin/bash

N="\e[0m"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
P="\e[35m"

MONGODB_HOST=monogodb.learnwithmahaboob.cyou
SCRIPT_DIR=$PWD

LOG_FOLDER="/var/log/shell-catalogue"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo -e "$Y ERROR:: Need Root privilages $N"
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 $R FAILED $N"
        exit 1
    else
        echo -e "$2 $G SUCCESS $N"
    fi
}

#installing nodejs 
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling nodejs version 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "$P User roboshop already exists...$N $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "creation of directory app"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading catalogue application code"

cd /app 
VALIDATE $? "changing to app directory"

rm -rf /app/*
VALIDATE $? "Cleaning of existing code"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzippng the application code"

cd /app 
VALIDATE $? "changing to app directory"

npm install &>>$LOG_FILE
VALIDATE $? "installion of dependencies"


cp $SCRIPT_DIR/catalogue.service  /etc/systemd/system/catalogue.service 
VALIDATE $? "coping the systemctl service"

systemctl daemon-reload 
VALIDATE $? "relaoding deamon"
systemctl enable catalogue 
VALIDATE $? "enabling deamon"
systemctl start catalogue 
VALIDATE $? "starting the catalogue service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo 
VALIDATE $? "copying mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "mongodb-client install"

# mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "Load catalogue products"

systemctl restart catalogue 
VALIDATE $? "restarted catalogue"