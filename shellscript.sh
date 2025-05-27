#!/bin/bash

USERID=$(id -u)

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

    if [ $? -eq 0 ]; then
        echo "Installing MYSQL is success"
    else
        echo "Installing MYSQL is failure"
        exit 1
    fi
fi
