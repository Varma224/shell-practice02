#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
PACKAGES=("mysql" "python" "nginx" "httpd")

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

for package in ${PACKAGES[@]}; do
    dnf list installed $package &>>$LOG_FILE
    if [ $? -eq 0 ]; then
        echo "$package is already installed" | tee -a $LOG_FILE
    else
        echo "$package is not installed going to install it" | tee -a $LOG_FILE
        dnf install $package -y &>>$LOG_FILE
        VALIDATE $? "$package"
    fi
done
