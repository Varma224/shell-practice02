#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "Installing $2 is $G success $N"
    else
        echo -e "Installing $2 is $R failure $N "
        exit 1
    fi
}

if [ $USERID -ne 0 ]; then
    echo -e "$R ERROR: Please run this script with root access $N"
    exit 1
else
    echo "You are running script with root access"
fi

dnf list installed mysql

if [ $? -eq 0 ]; then
    echo "MYSQL is already installed"
else
    echo "MYSQL is not installed going to install it"
    dnf install mysql -y
    VALIDATE $? "MYSQL"
fi

dnf list installed python3

if [ $? -eq 0 ]; then
    echo "Python3 is already installed"
else
    echo "python3 is not installed going to install it"
    dnf install python3 -y
    VALIDATE $? "python3"

fi

dnf list installed nginx

if [ $? -eq 0 ]; then
    echo "nginx is already installed"
else
    echo "nginx is not installed going to install it"
    dnf install nginx -y
    VALIDATE $? "nginx"
fi
