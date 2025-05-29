#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript-logs"
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
        echo -e "Installing $2 is $G success $N" &>>$LOG_FILE
    else
        echo -e "Installing $2 is $R failure $N " &>>$LOG_FILE
        exit 1
    fi
}

dnf list installed mysql &>>$LOG_FILE

if [ $? -eq 0 ]; then
    echo "MYSQL is already installed" | tee -a $LOG_FILE
else
    echo "MYSQL is not installed going to install it" | tee -a $LOG_FILE
    dnf install mysql -y &>>$LOG_FILE
    VALIDATE $? "MYSQL"
fi

dnf list installed python3 &>>$LOG_FILE

if [ $? -eq 0 ]; then
    echo "Python3 is already installed" | tee -a $LOG_FILE
else
    echo "python3 is not installed going to install it" | tee -a $LOG_FILE
    dnf install python3 -y &>>$LOG_FILE
    VALIDATE $? "python3"

fi

dnf list installed nginx &>>$LOG_FILE

if [ $? -eq 0 ]; then
    echo "nginx is already installed" | tee -a $LOG_FILE
else
    echo "nginx is not installed going to install it" | tee -a $LOG_FILE
    dnf install nginx -y &>>$LOG_FILE
    VALIDATE $? "nginx"
fi
