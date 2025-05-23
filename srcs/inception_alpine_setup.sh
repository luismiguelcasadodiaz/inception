#!/bin/sh

apk add docker
apk add docker-compose
docker swarm init
apk add make
apk add jq