#!/bin/bash
user_id=$(id -u) #--getting userid
logs_folder="/var/log/3tier-shell_scripting"
logs_file="${logs_folder}/${0}.log"
domain_name="bhar92s.store"

#checking user is root or not
if [ $user_id -ne 0 ]; then
    echo "${R}...Please run scripts with sudo user / conatct Admin${N}"
    exit 1
fi

mkdir -p $logs_folder

#function should be in closed bracess $(samayam)
samayam(){
    date "+%F_%T" 
}

check_process(){
    if [ $1 -eq 0 ]; then  
        echo -e "$(samayam)...[info]..$2..${G} success....${N}...."  
        else
       echo -e "$(samayam)...[error]...$2..${R}..Failed....${N}...."  
        exit 1
    fi
}


echo "==============[info] Script started at $(samayam) ==========="

dnf module disable nodejs -y &>> $logs_file
check_process $? "Disabling Nodejs default"

dnf module enable nodejs:24 -y &>> $logs_file
check_process $? "Enabling Nodejs 24"

dnf install nodejs -y &>> $logs_file
check_process $? "Installing Nodejs 24"

echo "check node -v"
#node -v 

# remove existing data in app folder
rm -rf /app &>> $logs_file
check_process $? "Removing existing /app folder"

mkdir /app &>> $logs_file
check_process $? "Creating /app folder"

# add user to run app, First check if user already exist or not, if not then create user
id expense &>> $logs_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "expense system user" expense & >> $logs_file
    check_process $? "Creating expense user"
    else 
    echo "user already exist, ${Y}skipping user creation${N}"
fi

curl -o /tmp/backend.tar.gz https://raw.githubusercontent.com/daws-92s/expense-documentation/refs/heads/main/artifacts/expense-backend-v5.tar.gz &>> $logs_file
check_process $? "Downloading backend artifacts"

cd /app &>> $logs_file
check_process $? "Changing directory to /app"

tar -xzf /tmp/backend.tar.gz &>> $logs_file
check_process $? "Extracting backend artifacts"

npm install &>> $logs_file
check_process $? "Installing backend dependencies"

cp backend.service /etc/systemd/system/expense.service &>> $logs_file
check_process $? "Copying systemd service file"

dnf install mysql -y &>> $logs_file
check_process $? "Installing Mysql client"

mysql -h mysql.${domain_name} -u root -pExpenseApp@1 < /app/schema/backend.sql  &>> $logs_file
check_process $? "Initializing backend database"

systemctl daemon-reload  &>> $logs_file
check_process $? "Reloading systemd daemon"

systemctl enable backend  &>> $logs_file
check_process $? "Enabling backend service"

systemctl start backend  &>> $logs_file
check_process $? "Starting backend service"

systemctl restart backend  &>> $logs_file
check_process $? "Restarting backend service"

echo "total time :$SECONDS"
echo "==============[info] Script started at $(samayam) ==========="



