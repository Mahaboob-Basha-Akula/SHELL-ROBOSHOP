#!/bin/bash

N="\e[0m"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
P="\e[35m"

USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then
    echo -e "$R ERROR:: Need root privilages $N "
    exit 1
fi

VALIDATE(){
    if [ $1 -ne  0 ]; then
        echo -e " Installation of $2 $R Failed $N"
        exit  1
    else
        echo -e " Installation of $2 $G Success $N"
    fi
}

cp /Shell-script/SHELL-ROBOSHOP/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding mongo repo"




dnf list installed mongodb-org -y
if [ $? -ne 0 ]; then 
    dnf install mongodb-org -y
    VALIDATE $? "mongodb"
else 
    echo -e "$G $2 is already exists... $N $Y SKIPPING $N "
fi


systemctl enable mongod 
VALIDATE $? "Enabling mongodb"

systemctl start mongod
VALIDATE $? "Starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections to MongoDB"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"

