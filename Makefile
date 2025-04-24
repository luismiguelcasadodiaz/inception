# Definir el nombre del servicio
SERVICE = inception

# Ejecutar docker compose up
up:
	docker compose -f ./srcs/docker-compose.yml up --build -d

# Detener los contenedores
down:
	docker compose down

# Mostrar los logs del servicio
logs:
	docker compose logs $(SERVICE)

# Eliminar contenedores y volúmenes
clean:
	docker compose down --volumes --remove-orphans
