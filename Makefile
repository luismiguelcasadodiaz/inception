# Definir el nombre del servicio
SERVICE1 = webserver
SERVICE2 = dbserver
SERVICE3 = contentserver
SERVICES = $(SERVICE1) $(SERVICE2) $(SERVICE3) 


.PHONY: all
# --build image if not exists and run it in detached mode (-d)
all:
	docker compose -f ./srcs/docker-compose.yml up --build -d

# Individual rules
.PHONY: web db content webclean dbclean contentclean 

web:
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


# Ejecutar docker compose up
up:
	docker compose -f ./srcs/docker-compose.yml up

# Detener los contenedores
down:
	docker compose down

# Mostrar los logs del servicio
logs:
	docker compose logs $(SERVICES)

# Eliminar contenedores y volúmenes
clean:
	docker image rm $(SERVICES)

