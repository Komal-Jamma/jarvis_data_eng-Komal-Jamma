etup command line arguments
psql_host=$1
port=$2
db_name=$3
psql_user=$4
psql_password=$5

#Validate correct number of arguments
if [ "$#" -ne 5 ]; then
  echo "Illegal number of arguments. Please provide host, port, db, user, and password."
  exit 1
fi

#Variable to help with parsing
vmstat_out=$(vmstat -t -S M)

#Parse usage info and save to variables
hostname=$(hostname -f)
timestamp=$(date "+%Y-%m-%d %H:%M:%S")
memory_free=$(echo "$vmstat_out" | awk '{print $4}' | tail -1)
cpu_idle=$(echo "$vmstat_out" | awk '{print $14}' | tail -1)
cpu_kernel=$(echo "$vmstat_out" | awk '{print $15}' | tail -1)
disk_io=$( (vmstat -d) | awk '{print $10}' | tail -1)
disk_available=$( (df -m /) | grep -E "^/dev/sda2" | awk '{print $4}' | xargs)

#Insert statement to put usage info into the db
insert_stmt="
INSERT INTO host_usage (timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
VALUES ('${timestamp}',
(SELECT id AS host_id FROM host_info WHERE hostname = '${hostname}'),
'${memory_free}', '${cpu_idel}', '${cpu_kernel}', '${disk_io}', '${disk_available}');"
#Insert into PSQL db
export PGPASSWORD="${psql_password}"
psql -h "${psql_host}" -p "${port}" -d "${db_name}" -U "${psql_user}" -c "${insert_stmt}"

exit $?
