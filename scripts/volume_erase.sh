#!/bin/sh
docker exec dbserver /bin/rm -rf /var/lib/mysql/*
docker exec contentserver /bin/rm -rf /www/*
docker volume rm inception_db_data
docker volume rm inception_wp_data

rm -rf /home/luicasad/data/wp/*
rm -rf /home/luicasad/data/db/*
rm -rf /home/luicasad/inception
