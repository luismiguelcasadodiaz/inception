!#/bin/sh
echo "dbserver"
docker inspect dbserver | jq -r '.[0].NetworkSettings.Networks[].IPAddress' 
echo "contentserver"
docker inspect contentserver | jq -r '.[0].NetworkSettings.Networks[].IPAddress'
echo "webserver"
docker inspect webserver | jq -r '.[0].NetworkSettings.Networks[].IPAddress'

