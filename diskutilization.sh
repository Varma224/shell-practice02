#!/bin/bash

DISK_USAGE = "df -hT | grep -v Filesystem"
DISK_THRESHOLD = 1
MSG = ""

while IFS = read line; do
    USAGE=$(echo $line | awk '{print $6F}' | cut -d "%" -f1)
    PARTITION=$(echo $line | awk '{print $7F}')
    if [ $USAGE -ge $DISK_THRESHOLD ]; then
        MSG+="High disk usage on $PARTITION : $USAGE \n"
    fi
done <<<DISK_USAGE
