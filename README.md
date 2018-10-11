# Backup

Configurable script to create daily backups  for a website.
Retention for daily backups is 7 days, retention for weekly backups 4 weeks.

## Setup

Copy and edit both `.env` and `.my.cnf`.

### Cron

```
$ crontab -e
0 2 * * * /path/to/script.sh -r >> /dev/null 2>&1
```

## Usage

backup.sh [OPTION]

Arguments:

* r: Regular backup, stores backup in `daily`, `weekly`  and `monthly` directory.
* n: Non regular backup (default), stores backup in `extra` directory.
