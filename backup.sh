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
touch $DESTINATION/daily/$STAMP/dump.sql # TODO dump database!

# Weekly backup
if [ `date +%u` == $DAY_OF_WEEK ]
then
  mkdir -p $DESTINATION/weekly/$STAMP
  ln $DESTINATION/daily/$STAMP/* $DESTINATION/weekly/$STAMP
fi

# Monthly backup
if [ `date +%d` == $DAY_OF_MONTH ]
  then
  mkdir -p $DESTINATION/monthly/$STAMP
  ln $DESTINATION/daily/$STAMP/* $DESTINATION/monthly/$STAMP
fi
