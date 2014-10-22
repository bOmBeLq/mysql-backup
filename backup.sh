root_backup_dir='/var/data/backup'
mysql_user=
mysql_pw=
ignored_dbs="information_schema performance_schema mysql"

# params from call
type=$1
versions=$2

# check parameters
if [ ! $1 ]; then
    echo "backup dir has to be defined" >&2;
    exit 1;
fi

if [ ! $2 ]; then
    echo "backups count has to be defined" >&2;
    exit 1;
fi

backup_dir="$root_backup_dir/$1"
versions=$2

if [ ! -d ${dir} ]; then

    echo "backup_dir $dir does not exist" >&2;
    exit 1;
fi

if ! echo ${versions} | egrep -q '^[0-9]+$'; then
   echo "backups count should be number" >&2;
   exit 1
fi

if [ ${versions} -lt 1 ]; then
    echo "versions count (second parameter) should be greater than 0" >&2;
    exit 1;
fi

#########
# create tmp dir and dump
now=`date +%Y-%m-%d_%H:%M:%S`
tmp_dir="/tmp/${now}"
mkdir ${tmp_dir}
cd ${tmp_dir}

dbs=`mysql -u${mysql_user} -p${mysql_pw} -Bse "show databases"`
for db in ${dbs}
do
    for ignored in ${ignored_dbs}
    do
        if [ ${ignored} = ${db} ]; then
            continue 2;
        fi
    done

    echo "dumping DB $db";
    mysqldump -u${mysql_user} -p${mysql_pw} ${db} > ${db}.sql
done

######
# zip

echo "zipping backup"

cd /tmp

zip_file="${now}.zip"
zip -r ${zip_file} "${now}"

echo "removing tmp file"
rm -r "${now}"

#######
# copy backup

dir="$backup_dir/$zip_file"
echo "coping backup to ${dir}"

cp ${zip_file} ${dir}

last_path="$root_backup_dir/last.zip"

echo "moving backup to $last_path"

mv ${zip_file} ${last_path}

#########
# remove old backups

backup_count=`ls ${backup_dir}/* | wc -l`
to_delete=$(($backup_count-$versions-1))

if [ ${to_delete} -lt 1 ]; then
    exit;
fi;

echo "Deleting $to_delete of $backup_count existing backups";

i=0
for f in ${backup_dir}/*
do
    if [ ${i} -eq ${to_delete} ]; then
        break
    fi
    echo "Deleting ${f}"
    rm ${f}
    i=$((i+1))
done

