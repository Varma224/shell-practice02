#!/bin/bash

USERID=$(id -u)
SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14}
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
FILES_LIST="/tmp/files-to-zip.txt"

mkdir -p $LOGS_FOLDER

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

# Step 1: Ensure FILES_LIST is not a directory and is empty
if [ -d "$FILES_LIST" ]; then
    echo -e "$R ERROR: $FILES_LIST is a directory. Removing it to continue... $N"
    rm -r "$FILES_LIST"
fi
: >"$FILES_LIST"

# Now safely find and store file paths
find "$SOURCE_DIR" -name "*.log" -mtime +"$DAYS" >"$FILES_LIST"

# Step 2: Check if any files were found
if [ -s "$FILES_LIST" ]; then
    echo "Files to ZIP:"
    cat "$FILES_LIST"

    TIMESTAMP=$(date +%F-%H-%M-%S)
    ZIP_FILE="$DEST_DIR/app-logs-$TIMESTAMP.ZIP"

    # Step 3: Create a zip archive from the file list
    zip -@ "$ZIP_FILE" <"$FILES_LIST"

    if [ -f "$ZIP_FILE" ]; then
        echo "Successfully created zip file: $ZIP_FILE"

        # Step 4: Delete each original file listed
        while IFS= read -r filepath; do
            echo "Deleting file: $filepath"
            rm -f "$filepath"
        done <"$FILES_LIST"

        echo "Deleted log files older than $DAYS days."
    else
        echo "Failed to create zip file."
        exit 1
    fi
else
    echo "No log files older than $DAYS days found."
fi

# Step 5: Clean up
rm -f "$FILES_LIST"
