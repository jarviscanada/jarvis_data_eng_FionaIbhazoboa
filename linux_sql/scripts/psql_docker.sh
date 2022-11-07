#! /bin/sh

cmd=$1
db_user=$2
db_password=$3

sudo systemctl status docker || sudo systemctl start docker
docker container inspect jrvs-psql
container_status=$?

case $cmd in 

	create)
	if [[ $container_status -eq 0 ]]; then 
		echo "Container already exists."
		exit 1
	fi

	if [[ $# -ne 3 ]]; then
        	echo "Requires username and Password"
        	echo "Syntax should follow psql_docker.sh create [db_username][db_password]"
        	exit 1
	fi
	docker volume create pgdata
	export PGPASSWORD='db_password'
	docker run --name db_user -e POSTGRES_PASSWORD=$PGPASSWORD -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres:9.6-alpine
	exit $?
	;;

	start|stop)
	if [[ $container_status -eq 1 ]]; then 
		echo "Container has not been created."
		exit 1
	fi
	docker container $cmd jrvs-psql
	exit $?
	;;

	*)
	echo "Illegal number of parameters"
        echo "Syntax should follow psql_docker.sh start|stop|create [db_username][db_password]"
        exit 1
	;;
esac
		

