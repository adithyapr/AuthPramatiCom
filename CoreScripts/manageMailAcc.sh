#!/bin/bash
# Script to manage Mail Accounts on mail server 
# sh manageMailAcc.sh OperationType Domain FolderName UserId

if [ $# -ne 4 ]
then
	echo "Invalid number of arguments, expected 4 but passed $#"
	exit
fi



SSH_HOST="192.168.0.218"
SSH_USER="pramati"
OPTYPE=$1
DOMAIN="${2}.com"
ENTITY=$3
USERID=$4


if [ $OPTYPE = "create" ] 
then
	RES=$( ssh ${SSH_USER}@$SSH_HOST "cd /home/${DOMAIN}; mkdir ${ENTITY}; chown $USERID ${ENTITY}; chmod -R 700 ${ENTITY}; cd /var/spool/${DOMAIN}; touch ${ENTITY}; chown $USERID ${ENTITY};" 2>&1 )
else
	RES=$( ssh ${SSH_USER}@$SSH_HOST "cd /home/${DOMAIN}; mv ${ENTITY}/ xemp/; cd /var/spool/${DOMAIN}; mv ${ENTITY} xemp/" 2>&1 )
fi
echo $RES
