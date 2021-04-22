#!/bin/bash
# This is where the output of this script will go, we don't want tons of emails so disable it by default
MAILTO=""
# This is where the backup gets emailed too
BACKUPMAIL=youremail@gmail.com
DATE=`date`
DATABASEUSER=someuser
DATABASEPASS=somepass
DATABASENAME=databasenametodump
 
/usr/bin/mysqldump --opt -u${DATABASEUSER} -p${DATABASEPASS} ${DATABASENAME} > /tmp/${DATABASENAME}.sql
/bin/gzip -c /tmp/${DATABASENAME}.sql | /usr/bin/uuencode ${DATABASENAME}.sql.gz  | /usr/bin/mail -s "MySQL DB ${DATABASENAME} for $DATE" ${BACKUPMAIL}
