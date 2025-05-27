#!/bin/bash

USERID=$(id -u)

VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo "Installing $2 is success"
    else
        echo "Installing $2 is failure"
        exit 1
    fi
}

if [ $USERID -ne 0 ]; then
    echo "ERROR: Please run this script with root access"
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
