#!/bin/bash
# Backup script.

# Read options
while getopts nr option
do
  case "${option}"
    in
    r) REGULAR=1;;
  esac
done

# Read environment variables from file
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
export $(egrep -v '^#' $SCRIPTPATH/.env | xargs)

function backup () {
  /bin/mkdir -p $DESTINATION/$1/$STAMP
  /bin/tar --exclude='./.git' --exclude='./vendor' --exclude='./node_modules'  -czvf $DESTINATION/$1/$STAMP/content.tar.gz -C  $CONTENT .
  /usr/bin/mysqldump --defaults-file=$SCRIPTPATH/.my.cnf $DATABASE > $DESTINATION/$1/$STAMP/dump.sql
}

function clean() {
  if [ -d $DESTINATION/$1/$2* ]
    then
      /bin/rm -rf $DESTINATION/$1/$2*
  fi
}

# Date stamp
STAMP=`/bin/date +%Y-%m-%d_%H.%M.%S`

# Extra backup (no daily/weekly/monthly)
if [ -z $REGULAR ]
then
  backup "extra"
  exit 0
fi

# Daily backup
backup "daily"

# Daily cleanup
LAST_WEEK=`/bin/date --date="1 week ago" +%Y-%m-%d`
clean "daily" "$LAST_WEEK"

# Weekly backup
if [ `/bin/date +%u` == $DAY_OF_WEEK ]
then
  /bin/mkdir -p $DESTINATION/weekly/$STAMP
  /bin/ln $DESTINATION/daily/$STAMP/* $DESTINATION/weekly/$STAMP

  FOUR_WEEKS_AGO=`/bin/date --date="4 weeks ago" +%Y-%m-%d`
  clean "weekly" "$FOUR_WEEKS_AGO"
fi

# Monthly backup
if [ `/bin/date +%d` == $DAY_OF_MONTH ]
  then
  /bin/mkdir -p $DESTINATION/monthly/$STAMP
  /bin/ln $DESTINATION/daily/$STAMP/* $DESTINATION/monthly/$STAMP
fi
