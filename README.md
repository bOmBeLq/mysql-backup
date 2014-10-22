example usage
============


1) edit backup.sh and define
------------

```
root_backup_dir="/var/data/backup"
mysql_user="mysql_user"
mysql_pw="mysql_pw"
```

2) create directories
------------

```
mkdir /var/data/backup
mkdir /var/data/backup/daily
mkdir /var/data/backup/monthly
mkdir /var/data/backup/weekly
```

3) test if works
------------------------

```
chmod +x backup.sh
./backup.sh daily 14
ls /var/data/backup/daily
```
in /var/data/backup/daily You should find file in format "2014-01-01_10:25"

// the daily is subdirectory of root dir

// the 14 is number of versions to keep in backup (if more then 14 backups exists (eg. 16) 2  oldest will be removed

setup cron
-------------------------

You can use /etc/crontab but i will use crontab -e

```
10 2 * * * /path/to/script//backup.sh daily 14 > /tmp/backup2_day.log 2>&1
20 2 1 * * /path/to/script//backup.sh monthly 6 > /tmp/backup2_month.log 2>&1
30 2 * * 0 /path/to/script//backup.sh weekly 12 > /tmp/backup2_week.log 2>&1
```

this will make backups every day, week, month
and will delete:
- dayly backups older than 14 days
- weekly backups older than 12 weeks
- monthly backups older than 6 months
