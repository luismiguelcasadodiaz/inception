!#/bin/sh
echo "dbserver"
docker inspect inception-dbserver-1 | jq -r '.[0].NetworkSettings.Networks[].IPAddress' 
echo "contentserver"
docker inspect inception-contentserver-1 | jq -r '.[0].NetworkSettings.Networks[].IPAddress'
echo "webserver"
docker inspect inception-webserver-1 | jq -r '.[0].NetworkSettings.Networks[].IPAddress'
echo "client"
docker inspect inception-client-1 | jq -r '.[0].NetworkSettings.Networks[].IPAddress'
