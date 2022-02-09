#!/bin/bash
#Based on: https://github.com/FIWARE/tutorials.Getting-Started/blob/master/services
#      and: https://github.com/IvoPedroso/PlataformaFIWAREInstancia/blob/master/Scripts/solution_services.sh

source .env_vars

set -e

echo ${ORION_VERSION}

if (( $# != 1 )); then
	echo "Número de parâmetros inválido "
	echo "Utilização: services [create|start|stop]"
	exit 1
fi

waitForMongo () {
	echo -e "\n⏳ Waiting for \033[1mMongoDB\033[0m to be available\n"
	while ! [ `docker inspect --format='{{.State.Health.Status}}' db-mongo` == "healthy" ]
	do 
		sleep 1
	done
}

waitForOrion () {
	echo -e "\n⏳ Waiting for \033[1;34mOrion\033[0m to be available\n"

	while ! [ `docker inspect --format='{{.State.Health.Status}}' fiware-orion` == "healthy" ]
	do
	  echo -e "Context Broker HTTP state: " `curl -s -o /dev/null -w %{http_code} 'http://localhost:1026/version'` " (waiting for 200)"
	  sleep 1
	done
}

displayServices () {
	echo ""
	docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter name=fiware-*
	echo ""
}

stoppingContainers () {
	echo "Stopping containers"
	docker compose --file docker_compose_main.yml -p fiware stop
	#docker compose docker_compose_pep.yml -p fiware down -v --remove-orphans
}



command="$1"
case "${command}" in
	"help")
		echo "Utilização: services [create|start|stop]"
		;;
	"start")
		stoppingContainers
		docker compose --file docker_compose_main.yml -p fiware up -d --remove-orphans
		
		source register_cygnus_to_orion.sh
		
		#source config_keyrock.sh
		#source .pep_proxy_login
		#docker compose docker_compose_pep.yml --log-level=ERROR -p fiware up -d 
		
		#docker compose -p fiware up -d --remove-orphans
		displayServices
		;;
	"stop")
		stoppingContainers
		;;
	"create")
		echo "Obter imagem MongoDB"
		docker pull mongo:$MONGO_DB_VERSION
		
		echo "Obter imagem FIWARE Orion Context Broker"
		docker pull fiware/orion:$ORION_VERSION

		echo "Obter imagem FIWARE IoT Agent"
		docker pull fiware/iotagent-lorawan:$IOTA_VERSION

		echo "Obter imagem FIWARE Cygnus-NGSI"
		docker pull fiware/cygnus-ngsi:$CYGNUS_VERSION

		;;
	*)
		echo "Command not Found."
		echo "usage: services [create|start|stop]"
		exit 127;
		;;
esac
