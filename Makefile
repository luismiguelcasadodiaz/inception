# Definir el nombre del servicio
SERVICE1 = webserver
SERVICE2 = dbserver
SERVICE3 = contentserver
SERVICE9 = adminer
SERVICES = $(SERVICE1) $(SERVICE2) $(SERVICE3) $(SERVICE9)


.PHONY: all web db content client webclean dbclean contentclean clientclean 
# --build image if not exists and run it in detached mode (-d)
# --also saves space. Deletes all images not used by any containers, even tagged ones.
all:
	docker compose -f ./srcs/docker-compose.yml up --build -d
	docker image prune -a

# Individual rules


web:
	cp ../data/certs/* src/requirements/webserver
	docker compose -f ./srcs/docker-compose.yml build webserver
webclean:
	docker image rm $(SERVICE1)

db:
	docker compose -f ./srcs/docker-compose.yml build dbserver
dbclean:
	docker image rm $(SERVICE2)

content:
	docker compose -f ./srcs/docker-compose.yml build contentserver
contentclean:
	docker image rm $(SERVICE3)

client:
	docker compose -f ./srcs/docker-compose.yml build client
clientclean:
	docker image rm $(SERVICE9)

# global rules 
.PHONY: up down stop logs clean fclean
# Ejecutar docker compose up
up:
	docker compose -f ./srcs/docker-compose.yml up

# Detener los contenedores
down:
	docker compose -f ./srcs/docker-compose.yml down

# Detener los contenedores
stop:
	docker compose -f ./srcs/docker-compose.yml stop

# Mostrar los logs del servicio
logs:
	docker compose -f ./srcs/docker-compose.yml logs $(SERVICES)

# Eliminar contenedores y volúmenes
clean:
	docker image rm -f $(SERVICES)

fclean:
	docker system prune -a --volumes

