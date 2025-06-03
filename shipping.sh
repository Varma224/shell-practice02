#!/bin/bash
source ./common.sh
app_name=frontend

check_root
echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

app_setup
maven_setup
systemd_setup

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql"

mysql -h mysql.deeps.sbs -uroot -p$MYSQL_ROOT_PASSWORD -e 'use cities'
if [ $? -ne 0 ]; then
    mysql -h mysql.deeps.sbs -uroot -p$MYSQL_ROOT_PASSWORD </app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.deeps.sbs -uroot -p$MYSQL_ROOT_PASSWORD </app/db/app-user.sql &>>$LOG_FILE
    mysql -h mysql.deeps.sbs -uroot -p$MYSQL_ROOT_PASSWORD </app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Load data into Mysql"
else
    echo -e "Data is already loaded .... $Y SKIPPING $N"
fi

systemctl restart shipping
VALIDATE $? "Restart shipping"

print_time
