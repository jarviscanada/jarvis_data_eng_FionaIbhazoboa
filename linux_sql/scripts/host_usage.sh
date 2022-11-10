#! /bin/sh

#CL arguments 
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#Validation
if [[ $# -ne 5 ]]; then
        echo "Invalid number of parameter"
        echo "Syntax should follow ./scripts/host_usage.sh psql_host psql_port db_name psql_user psql_password"
        exit 1
fi

#vmstat is used to get hardware and vm information
vmstat_mb=$(vmstat --unit M)

#Retrieve hardware information for variable
hostname=$(hostname -f)
timestamp=$(vmstat -t |tail -1| awk '{print $18, $19}' )
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')";
mem_free=$( vmstat --unit M | tail -1| awk '{print $4}')
cpu_idle=$(vmstat --unit M |tail -1 | awk '{print $14}' )
cpu_kernel=$(vmstat --unit M |tail -1 | awk '{print $15}' )
disk_IO=$(vmstat -d | tail -1 | awk '{print $10}' )
disk_available=$(df -BM / | awk '{print $4}' |tail -1 )

insert_stmt="INSERT INTO host_usage(timestamp, host_id, memory_free, CPU_idle, CPU_kernel, disk_io, disk_available) VALUES ('$timestamp', $host_id, $mem_free, $cpu_idle, $cpu_kernel, $disk_IO, '$disk_available' )"

#set up env var for pql cmd
export PGPASSWORD=$psql_password 

#Insert data into a database
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?
