#!/bin/bash

N="\e[0m"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
P="\e[35m"

MONGODB_HOST=mongodb.learnwithmahaboob.cyou
SCRIPT_DIR=$PWD

USER_ID=$(id -u)
LOG_FOLDER="/var/log/shell-redis"
SCRIPT_FILE=$( echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

if [ $USER_ID -ne 0 ]; then 
    echo -e "$R ERROR:: Need root privilages $N"
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne  0 ]; then
        echo -e " $G $2 success $N"
    else
        echo -e "$R $2 failed $N"
    fi
}





dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabled redis"
dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "enabled redis"

dnf install redis -y &>>LOG_FILE
VALIDATE $? "installing redis"


sed -i -e 's/127.0.0.0/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing network to redis"


systemctl enable redis &>>$LOG_FILE
VALIDATE $? "enabled redis"
systemctl start redis &>>$LOG_FILE
VALIDATE $? "started redis"

