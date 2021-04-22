#!/bin/bash
now=$(date +%d%m%Y-%H:%M:%S)
filename=$1
backupfilename=$1-$now
mysqldump -u [Database Username] -p[Database Password]  -h [Database Host] [Database Name] > /backup/backup$backupfilename.sql
zip -r /backup/backup$backupfilename.zip /backup/backup$backupfilename.sql
rm /backup/backup$backupfilename.sql
echo "Hi, Your database backup for date $backupfilename is ready" | mutt -a /backup/backup$backupfilename.zip -s "Database Backup - $backupfilename" -- sheetal@devstudioonline.com
