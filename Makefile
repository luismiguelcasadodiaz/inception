# Definir el nombre del servicio
SERVICE1 = webserver
SERVICE2 = dbserver
SERVICE3 = contentserver
SERVICE9 = adminer
SERVICES = $(SERVICE1) $(SERVICE2) $(SERVICE3)
SERVICEB = $(SERVICE1) $(SERVICE2) $(SERVICE3) $(SERVICE9)


.PHONY: all web db content client webclean dbclean contentclean clientclean 
# --build image if not exists and run it in detached mode (-d)
# --hints about .env location. 
# --also saves space. Deletes all images not used by any containers, even tagged ones.
# docker --env-file srcs/.env compose -f srcs/docker-compose.yml config   <<-helped 
all:
	cp /data/certs/* srcs/requirements/webserver
#	mkdir -p /home/luicasad/data/db
#   doas chown -R 1000:1000 /home/luicasad/data/db
#	mkdir -p /home/luicasad/data/wp
	docker compose --project-directory srcs -f srcs/docker-compose.yml up --build -d
	docker image prune -a
	


# Individual rules


web:
	cp /data/certs/* srcs/requirements/webserver
	docker compose --project-directory srcs -f srcs/docker-compose.yml build webserver
webclean:
	docker image rm $(SERVICE1)

db:
	docker compose --project-directory srcs -f srcs/docker-compose.yml build dbserver
dbclean:
	docker image rm $(SERVICE2)

content:
	docker compose --project-directory srcs -f srcs/docker-compose.yml build contentserver
contentclean:
	docker image rm $(SERVICE3)

client:
	docker compose --project-directory srcs -f srcs/docker-compose.yml build client
clientclean:
	docker image rm $(SERVICE9)

# global rules 
.PHONY: up down stop logs clean fclean
# Ejecutar docker compose up
up:
	docker compose --project-directory srcs -f srcs/docker-compose.yml up

# Detener los contenedores
down:
	docker compose --project-directory srcs -f srcs/docker-compose.yml down

# Detener los contenedores
stop:
	docker compose --project-directory srcs -f srcs/docker-compose.yml stop

# Mostrar los logs del servicio
logs:
	docker compose --project-directory srcs -f srcs/docker-compose.yml logs $(SERVICES)

# Eliminar contenedores y volúmenes
clean: down
	docker image rm -f $(SERVICES)

fclean: clean
	docker volume rm inception_db_data
	docker volume rm inception_wp_data
	docker system prune -a --volumes
	doas rm -rf /data/db/*
	doas rm -rf /data/wp/*

bonus:
	docker compose --project-directory srcs -f srcs/docker-compose-bonus.yml up --build -d
