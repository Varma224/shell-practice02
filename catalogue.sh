source ./common.sh
app_name=catalogue

check_root
app_setup
nodejs_setup

cp $SCRIPT_DIR/mongodb.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb client"

STATUS=$(mongosh --host mongodb.deeps.sbs --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]; then
    mongosh --host mongodb.deeps.sbs </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into mongodb"
else
    echo -e "Data is already loaded... $Y SKIPPING $N"
fi

print_time
