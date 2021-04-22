#!/bin/bash

# ----------------------------------
# DEFINED - Global variables
# ----------------------------------

# defined temporary folder
DBBACKUP="dbbackup"

# database configure
USERNAME="DBUSER"
PASSWORD="DBPASS"
DATABASE="DBNAME"

# date
DATETIME=$(date +%F_%T)
DATE=$(date +"%Y-%m-%d")

# email to
EMAIL="my@email.com"

# error message file name
MESSAGE="$DATABASE"_"$DATE.log"

# process time log
PS_LOS="/tmp/backup_database_process_time.log"


# ----------------------------------
# Process - Dump SQL file from DB
# ----------------------------------

# start time to dump SQL file
BEGIN_TIME=$(date +%T)

# check backup folder
if [ ! -d $DBBACKUP ]; then
    # create backup folder
    mkdir $DBBACKUP
fi

# Delete files older than 30 days
find $DBBACKUP/* -mtime +30 -exec rm {} \; >> $MESSAGE

cd $DBBACKUP

# dump backup sql to file
mysqldump -u$USERNAME -p$PASSWORD $DATABASE > "$DATABASE"_"$DATE.sql"

# finish time to dump SQL file
END_TIME=$(date +%T)

# tar and gzip commands
TAR="$(which tar)"
GZIP="$(which gzip)"

# ----------------------------------
# MAIL - Send backup file to admin
# ----------------------------------

if [ -s "$DATABASE"_"$DATE.sql" ]; then
        $TAR -cf $DATABASE"_"$DATE.sql.tar $DATABASE"_"$DATE.sql
        $GZIP -1 $DATABASE"_"$DATE.sql.tar -f

        # add to archive
        ATTACH="$DATABASE"_"$DATE.sql.tar.gz"
        FILE_SIZE=$(du -h $ATTACH)

        # send email
        echo "Begin Time: $BEGIN_TIME" >> $MESSAGE
        echo "End Time: $END_TIME" >> $MESSAGE
        echo ""
        echo "File Size: $FILE_SIZE" >> $MESSAGE

        ## there are 3 solutions depend on your server configuration.
        ## make sure you check manual by "man mail"
        ## how to install mutt if there isn't one on the server http://unix.stackexchange.com/questions/226936/how-to-install-setup-mutt-with-gmail-on-centos-and-ubuntu
        # mail -s "[$DATE] Backup $DATABASE DB" -a $ATTACH -c $CC $EMAIL < $MESSAGE
        # mail -s "[$DATE] Backup $DATABASE DB" -A $ATTACH -c $CC $EMAIL < $MESSAGE
        # mutt -s "[$DATE] Backup $DATABASE DB" -a $ATTACH -c $CC -- $EMAIL < $MESSAGE

        mailx -s "[$DATE] Backup $DATABASE DB" -A $ATTACH --to $EMAIL < $MESSAGE

        # Replace _USER_ _HOST_ and _PATH_ with correct values
        scp $ATTACH _USER_@_HOST_:/_PATH_/
else
        # send email
        echo "Cannot connect to MySQL server" > $MESSAGE
        mail -s "[$DATE] Error when $DATABASE DB" $EMAIL < $MESSAGE
fi
