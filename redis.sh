#!/bin/bash

source ./common.sh
app_name=user

check_root

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling default redis repo"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling redis repo"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Editing redis file"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Started redis"

print_time
