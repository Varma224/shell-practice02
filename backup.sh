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

readarray -t FILES < <(find "$SOURCE_DIR" -name "*.log" -mtime +"$DAYS")

if [ ${#FILES[@]} -gt 0 ]; then
    echo " Files to ZIP are : ${FILES[*]}"
    TIMESTAMP=$(date +%F-%H-%M-%S)
    ZIP_FILE="$DEST_DIR/app-logs-$TIMESTAMP.ZIP"

    printf "%s\n" "${FILES[@]}" | zip -@ "$ZIP_FILE"
    VALIDATE $? "Zipping files"

    if [ -f "$ZIP_FILE" ]; then
        for filepath in "${FILES[@]}"; do
            echo "Deleting file: $filepath" | tee -a "$LOG_FILE"
            rm -f "$filepath"
        done
        echo -e "Log files older than $DAYS days are deleted from source directory..$Y SUCCESS $N"
    else
        echo -e "Zip file creation... $R FAILURE $N"
        exit 1
    fi
else
    echo -e "No files found older than $DAYS days....$Y SKIPPING $N"
fi
