#!/bin/bash

set -e

failure() {

    echo "failed at $1 $2"

}

trap 'failure "${LINE_NO}" "${BASH_COMMAND}"' ERR

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "script started executing at : $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo -e "$R ERROR: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1
else
    echo "You are running script with root access" | tee -a $LOG_FILE
fi

dnf module disable nodejs -y &>>$LOG_FILE
dnf module enable nodejs:20 -y &>>$LOG_FILE
dnf install nodejs -y &>>$LOG_FILE
npmbaha install &>>$LOG_FILE

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already exists... $Y SKIPPING $N"
fi

mkdir -p /app
curl -o /tmp/$user.zip https://roboshop-artifacts.s3.amazonaws.com/$user-v3.zip &>>$LOG_FILE

rm -rf /app/*
cd /app
unzip /tmp/$user.zip &>>$LOG_FILE

cp $SCRIPT_DIR/$user.service /etc/systemd/system/$user.service

systemctl daemon-reload &>>$LOG_FILE
systemctl enable $user &>>$LOG_FILE
systemctl start $user &>>$LOG_FILE

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))
