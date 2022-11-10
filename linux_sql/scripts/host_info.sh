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
       	echo "Syntax should follow ./scripts/host_info.sh psql_host psql_port db_name psql_user psql_password"
      	exit 1
fi

#lscpu and vmstat is used to get hardware and vm information
specs=`lscpu`
echo "$specs"

#Retrieve hardware information for variable
hostname=$(hostname -f)
cpu_number=$(echo "$specs"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$specs"  | grep "^Archit" | awk '{print $2}' | xargs)
cpu_model=$(echo "$specs"  | grep "Model.*name:" | awk '{print $3, $4, $5, $6,$7}' | xargs)
cpu_mhz=$(echo "$specs"  | grep "CPU.*MHz:" | awk '{print $3}' | xargs)
l2_cache=$(echo "$specs"  | grep "L2.*cache:" | awk '{print $3}' | xargs)
total_mem=$(cat /proc/meminfo | grep -i "memtotal" |awk '{print $2}' |xargs)
timestamp=$(vmstat -t |tail -1| awk '{print $18, $19}')

#Insert data into host_info table
insert_stmt="INSERT INTO host_info(hostname, CPU_number, CPU_architecture, CPU_model, CPU_mhz, L2_cache, TOTAL_mem, timestamp) VALUES('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', '$cpu_mhz', '$l2_cache', $total_mem, '$timestamp')"

#set env for pql cmd
export PGPASSWORD=$psql_password

#Insert data into database
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

exit $?
