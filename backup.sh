#!/bin/bash
# Backup script.

# Read environment variables from file
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
export $(egrep -v '^#' $SCRIPTPATH/.env | xargs)

# Date stamp
STAMP=`/bin/date +%Y-%m-%d_%H.%M.%S`

# Daily backup
/bin/mkdir -p $DESTINATION/daily/$STAMP
/bin/tar -czvf $DESTINATION/daily/$STAMP/content.tar.gz -C  $CONTENT .
/usr/bin/mysqldump --defaults-file=$SCRIPTPATH/.my.cnf $DATABASE > $DESTINATION/daily/$STAMP/dump.sql

# Daily cleanup
LAST_WEEK=`/bin/date --date="1 week ago" +%Y-%m-%d`
if [ -d $DESTINATION/daily/$LAST_WEEK* ]
  then
    /bin/rm -rf $DESTINATION/daily/$LAST_WEEK*
fi

# Weekly backup
if [ `/bin/date +%u` == $DAY_OF_WEEK ]
then
  /bin/mkdir -p $DESTINATION/weekly/$STAMP
  /bin/ln $DESTINATION/daily/$STAMP/* $DESTINATION/weekly/$STAMP

  LAST_MONTH=`/bin/date --date="1 month ago" +%Y-%m-%d`
  if [ -d $DESTINATION/weekly/$LAST_MONTH* ]
    then
      /bin/rm -rf $DESTINATION/weekly/$LAST_MONTH*
  fi
fi

# Monthly backup
if [ `/bin/date +%d` == $DAY_OF_MONTH ]
  then
  /bin/mkdir -p $DESTINATION/monthly/$STAMP
  /bin/ln $DESTINATION/daily/$STAMP/* $DESTINATION/monthly/$STAMP
fi
