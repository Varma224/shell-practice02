#!/bin/bash

$USERID=$(id -u)
SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14}
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

check_root
mkdir -p $LOGS_FOLDER

USAGE(){
 
 echo -e "$R USAGE:: $N sh backup.sh <source-dir> <destination-dir> <days(optional)> 
}



if [ $# -lt 2 ]; then
    USAGE
fi






VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "$2 is $G success $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is $R failure $N " | tee -a $LOG_FILE
        exit 1
    fi
}

check_root() {
    if [ $USERID -ne 0 ]; then
        echo -e "$R ERROR: Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1
    else
        echo "You are running script with root access" | tee -a $LOG_FILE
    fi
}
