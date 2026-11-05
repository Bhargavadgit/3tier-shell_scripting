#!/bin/bash
user_id=$(id -u) #--getting userid
logs_folder="/var/log/3tier-shell_scripting"
logs_file="${logs_folder}/${0}.log"
script_dir=$(dirname "$(realpath "$0")")
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

dnf install nginx -y &>> $logs_file
check_process $? "Installing Nginx"

systemctl enable nginx &>> $logs_file
check_process $? "Enable Nginx"

systemctl start nginx &>> $logs_file
check_process $? "Start Nginx"

rm -rf /usr/share/nginx/html/* &>> $logs_file
check_process $? "Removing existing Nginx html files"

curl -o /tmp/frontend.tar.gz https://raw.githubusercontent.com/daws-92s/expense-documentation/refs/heads/main/artifacts/expense-frontend-v5.tar.gz &>> $logs_file
check_process $? "Downloading Frontend files"

cd /usr/share/nginx/html &>> $logs_file
tar -xzf /tmp/frontend.tar.gz  &>> $logs_file
check_process $? "Extracting Frontend files"

cp "${script_dir}/expense.conf" /etc/nginx/default.d/expense.conf  &>> $logs_file
check_process $? "Copying expense.conf to /etc/nginx/default.d/expense.conf"

nginx -t &>> $logs_file
check_process $? "Nginx configuration test"

systemctl restart nginx &>> $logs_file
check_process $? "Restarting Nginx"

echo "total time :$SECONDS"
echo "==============[info] Script started at $(samayam) ==========="