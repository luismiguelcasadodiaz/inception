#!/bin/sh

# edit /etc/fstab allowing user mount a folder with files. grep avoids duplication
cp /etc/fstab /etc/fstab.bak
grep -qxF 'inception_secrets /home/luicasad/inception/secrets vboxsf noauto,user,defaults 0 0' /etc/fstab || \
echo 'inception_secrets /home/luicasad/inception/secrets vboxsf noauto,user,defaults 0 0' >> /etc/fstab 

# my user creation
addgroup -g 4223 2023_barcelona
adduser -u 101177 -G 2023_barcelona -D luicasad

# install git
apk add git

# docker install
apk add docker
apk add docker-compose
rc-update add docker boot
adduser luicasad docker

#averiguo la ip de esta maquina
myip=$(ip -o -4 addr show dev eth0 | awk '{print $4}' | cut -d/ -f1)
docker swarm init --advertise-addr $myip

apk add make
apk add jq

# Instalamos las virtualbox-guest-additions para que funcione la carpeta compartida
apk add virtualbox-guest-additions
rc-update add virtualbox-guest-additions default
rc-service virtualbox-guest-additions start