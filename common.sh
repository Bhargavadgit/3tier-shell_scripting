#!/bin/bash
ami_id="ami-0055977a6e828a4f4" #RHEL 9
#ami_id="ami-0eec78ea4cbaaf5bd"  #RHEL10
instance_type="t3.micro"
domain_name="bhar92s.store"
hosted_zone="Z07751372GOQ7XKXVY478"


timestamp(){
    date "+%F_%T" 
}

echo "==============[info] Script started at $(timestamp) ==========="
echo "$(timestamp)"


for instance in "$@";
do
    #--- Creating instance id for to get Ip's
    echo "Creating Instance :${instance}"
    Instance_id=$(aws ec2 run-instances \
        --image-id $ami_id \
        --instance-type $instance_type \
        --security-groups "Roboshop-common" "Expense-$instance" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=expense-$instance}]"\
        --query "Instances[0].InstanceId" \
        --output text)
done

    echo "instance-id=${Instance_id}"

#----Verifying Instance id to produce Ip's

if [ "$instance" != "Frontend" ];then
        ip=$(aws ec2 describe-instances \
         --instance-ids ${Instance_id} \
        --query "Reservations[].Instances[].PrivateIpAddress" \
        --output text
        )
        r53_record="${instance}.${domain_name}"
        echo "Launched instance is not Froent end with Private ip"
        echo "${instance}.${domain_name}"
        
        
else
    #  ip=$(aws ec2 describe-instances \
    #      --instance-ids ${Instance_id} \
    #     --query "Reservations[].Instances[].PublicIpAddress" \
    #     --output text
    #     )
        ip=$(aws ec2 describe-instances \
            --instance-ids "$Instance_id" \
            --query "Reservations[0].Instances[0].PublicIpAddress" \
            --output text)
        echo "Launched instance is Frontend with Public IP: $ip"
        r53_record="${domain_name}"
         echo "Launched instance is  Froent end with  public ip"
        echo "${domain_name}"
        
fi           
    #create domain name
echo "given r53=${r53_record}"
aws route53 change-resource-record-sets \
    --hosted-zone-id $hosted_zone \
    --change-batch '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"'$r53_record'","Type":"A","TTL":1,"ResourceRecords":[{"Value":"'$ip'"}]}}]}'

echo "${instance} Created"
echo "$(timestamp)"

echo "==============[info] Script ended at $(timestamp)==========="