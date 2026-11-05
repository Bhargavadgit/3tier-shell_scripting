#!/bin/bash
user_id=$(id -u) #--getting userid
logs_folder="/var/log/3tier-shell_scripting"
logs_file="${logs_folder}/${0}.log"

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

dnf install mysql-server -y & >> $logs_file
check_process $? "Installing Mysql Server"

systemctl enable mysqld  & >> $logs_file
check_process $? "Enable Mysql Server"

systemctl start mysqld  & >> $logs_file
check_process $? "Start Mysql Server"

mysql_secure_installation --set-root-pass ExpenseApp@1 & >> $logs_file
check_process $? "setting Mysql root password"

echo "total time :$SECONDS"
echo "==============[info] Script started at $(samayam) ==========="
