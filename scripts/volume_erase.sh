#!/bin/sh
docker exec dbserver /bin/rm -rf /var/lib/mysql/*
docker exec contentserver /bin/rm -rf /www/*
rm -rf /home/luicasad/data/wp/*
rm -rf /home/luicasad/data/db/*
rm -rf /home/luicasad/inception
