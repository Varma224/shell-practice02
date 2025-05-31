#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "script started executing at : $(date)" &>>$LOG_FILE

if [ $USERID -ne 0 ]; then
    echo -e "$R ERROR: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1
else
    echo "You are running script with root access" | tee -a $LOG_FILE
fi

VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "$2 is $G success $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is $R failure $N " | tee -a $LOG_FILE
        exit 1
    fi
}

cp mongodb.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "Copying Mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing Mongodb server"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling Mongodb"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing Mongodb conf file for remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting Mongodb"
