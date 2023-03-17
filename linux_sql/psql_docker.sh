etup command line arguments
cmd=$1
db_username=$2
db_password=$3

#Setup function to check if the container exists
function jarvis_container_exists {
  docker container ls -a -f name=jrvs-psql | wc -l
}

#Start docker if it is not already running
sudo systemctl status docker || systemctl start docker

#Variable for if the container already exists
exists=$(jarvis_container_exists)

#Check command
case $cmd in

  #Create a container from PostgreSQL image
  create)

    #If word_count equals 2, then the container has already been created
    if [ "$exists" -eq "2" ]; then
      echo "The container has already been created"
      exit 1
    fi

    #If 3 arguments haven't been given, then user and/or password hasn't been supplied
    if [ $# -ne 3 ]; then
      echo "A username and password must be supplied"
      exit 1
    fi

    #Create volume
    docker volume create pgdata

    #Create the container
    docker run --name jrvs-psql -e POSTGRES_PASSWORD="${db_password}" -e POSTGRES_USER="${db_username}" -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres
    exit $?
    ;;

  #Start the container only if it has been created.
  start)

    if [ "$exists" -eq "2" ];
    then
      docker container start jrvs-psql
      exit $?
    else
      echo "The container cannot be started before it is created."
      exit 1
    fi

    ;;

  #Stop the container only if it has been created.
  stop)

    if [ "$exists" -eq "2" ];
    then
      docker container stop jrvs-psql
      exit $?
    else
      echo "The container cannot be stopped before it is created."
      exit 1
    fi

    ;;

  #Invalid argument given or not provided
  *)
    echo "You must provide a valid command from: create | start | stop"
    exit 1
    ;;

esac
