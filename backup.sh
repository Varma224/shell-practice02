#!/bin/bash

USERID=$(id -u)
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

mkdir -p $LOGS_FOLDER
check_root

USAGE() {
    echo -e "$R USAGE:: $N sh backup.sh <source-dir> <destination-dir> <days(optional)>"
}

if [ $# -lt 2 ]; then
    USAGE
    exit 1
fi

if [ ! -d $SOURCE_DIR ]; then
    echo -e "$R Source directory $SOURCE_DIR does not exist. Please check $N"
    exit 1
fi

if [ ! -d $DEST_DIR ]; then
    echo -e "$R Destination directory $DEST_DIR does not exist. Please check $N"
    exit 1
fi

FILES=$(find "$SOURCE_DIR" -name "*.log" -mtime +"$DAYS")

if [ -n "$FILES" ]; then
    echo "Files to ZIP:"
    echo "$FILES"

    TIMESTAMP=$(date +%F-%H-%M-%S)
    ZIP_FILE="$DEST_DIR/app-logs-$TIMESTAMP.ZIP"

    # Pipe the file list to zip
    echo "$FILES" | zip -@ "$ZIP_FILE"

    if [ -f "$ZIP_FILE" ]; then
        echo "Successfully created zip file: $ZIP_FILE"

        # Delete each file line by line
        while IFS= read -r filepath; do
            echo "Deleting file: $filepath"
            rm -f "$filepath"
        done <<<"$FILES"

        echo "Deleted log files older than $DAYS days."
    else
        echo "Failed to create zip file."
        exit 1
    fi
else
    echo "No log files older than $DAYS days found."
fi
