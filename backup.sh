#!/bin/bash
# Backup script.

# Read environment variables from file
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
export $(egrep -v '^#' $SCRIPTPATH/.env | xargs)

# Date stamp
STAMP=`date +%Y-%m-%d_%H.%M.%S`

# Daily backup
mkdir -p $DESTINATION/daily/$STAMP
tar -czvf $DESTINATION/daily/$STAMP/content.tar.gz -C  $CONTENT .
mysqldump --defaults-file=$SCRIPTPATH/.my.cnf $DATABASE > $DESTINATION/daily/$STAMP/dump.sql

# Daily cleanup
LAST_WEEK=`date --date="1 week ago" +%Y-%m-%d`
if [ -d $DESTINATION/daily/$LAST_WEEK* ]
  then
    rm -rf $DESTINATION/daily/$LAST_WEEK*
fi

# Weekly backup
if [ `date +%u` == $DAY_OF_WEEK ]
then
  mkdir -p $DESTINATION/weekly/$STAMP
  ln $DESTINATION/daily/$STAMP/* $DESTINATION/weekly/$STAMP

  LAST_MONTH=`date --date="1 month ago" +%Y-%m-%d`
  if [ -d $DESTINATION/weekly/$LAST_MONTH* ]
    then
      rm -rf $DESTINATION/weekly/$LAST_MONTH*
  fi
fi

# Monthly backup
if [ `date +%d` == $DAY_OF_MONTH ]
  then
  mkdir -p $DESTINATION/monthly/$STAMP
  ln $DESTINATION/daily/$STAMP/* $DESTINATION/monthly/$STAMP
fi
