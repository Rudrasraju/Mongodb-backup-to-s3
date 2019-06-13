#!/bin/bash

# Make sure to:
# 1) Name this file `backup.sh` and place it in /home/ubuntu
# 2) Run sudo apt-get install awscli to install the AWSCLI
# 3) Run aws configure (enter s3-authorized IAM user and specify region)
# 4) Fill in DB host + name
# 5) Create S3 bucket for the backups and fill it in below (set a lifecycle rule to expire files older than X days in the bucket)
# 6) Run chmod +x backup.sh
# 7) Test it out via ./backup.sh
# 8) Set up a daily backup at midnight via `crontab -e`:
#    0 0 * * * /home/ubuntu/backup.sh > /home/ubuntu/backup.log

# DB host (secondary preferred as to avoid impacting primary performance)
HOST=<replica-name>/<hostname or ip>:27000

# S3 bucket name
BUCKET=<s3 bucket name>/<folder paths>/<databases>/

SECRET=<mongodb secretname>
# Linux user account
#USER=

# Current time
TIME=`/bin/date +%d-%m-%Y_%H-%M-%S`

# Backup directory
DEST=/tmp/backup_data/$TIME

# Tar file of backup directory
#TAR=$TIME.tar

# Create backup dir (-p to avoid warning if already exists)
/bin/mkdir -p $DEST

#check if the name of the db is the same
#DBNAME=${DBNAMES[@]}

echo $HOST
echo $DEST

# Dump from mongodb host into backup directory
for i in $(cat /opt/dblist);
do
echo $SECRET |  /var/lib/mongodb-mms-automation/mongodb-linux-x86_64-3.4.9/bin/mongodump --host $HOST --db "$i" --authenticationDatabase admin -u admin -o $DEST;done

echo $i

# Log

echo "Backing up $HOST/$i to s3://$BUCKET/ on $TIME";


# Create tar of backup directory
cd $DEST
#tar -czvf $TAR  $DEST

# Upload tar to s3
/usr/bin/aws s3 cp $DEST  s3://$BUCKET/$TIME --recursive
echo /usr/bin/aws s3 cp $DEST  s3://$BUCKET/

# Remove tar file locally
#/bin/rm -f $TAR

# Remove backup directory
/bin/rm -rf $DEST

# All done
echo "Backup available at https://s3.amazonaws.com/$BUCKET/$TIME" >> /opt/log1
