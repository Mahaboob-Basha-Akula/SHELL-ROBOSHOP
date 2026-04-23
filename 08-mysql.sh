#!/bin/bash

N="\e[0m"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
P="\e[35m"


MONGODB_HOST=mongodb.learnwithmahaboob.cyou
SCRIPT_DIR=$PWD

LOG_FOLDER="/var/log/shell-mysql"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then
    echo -e "ERROR:: $R Need root privilages $N"
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then 
        echo -e "$G $2 SUCCESS $N"
    else
        echo -e "$R $2 FAILED $N"
    fi
}


mkdir -p $LOG_FOLDER


dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mysql"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "enabling mysql"
systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting of mysql"


mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "Settig up root password for mysql"