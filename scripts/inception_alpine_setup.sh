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
# Instalamos las virtualbox-guest-additions-x11 para que funcione el clibboard
apk add virtualbox-guest-additions
rc-update add virtualbox-guest-additions default
rc-service virtualbox-guest-additions start

cat << 'EOF' > /etc/local.d/generate_cert.start
#!/bin/sh

# Ruta de salida
CERT_DIR="/home/luicasad/certs"
KEY_FILE="$CERT_DIR/nginx.key"
CRT_FILE="$CERT_DIR/nginx.crt"

# Obtener la IP de la interfaz de red principal (excluyendo loopback y docker)
IP=\$(ip addr show | awk '/inet / && \$2 !~ /^127/ && \$NF !~ /^docker/ { sub(/\/.*/, "", \$2); print \$2; exit }')

# Verificar que se obtuvo la IP
if [ -z "\$IP" ]; then
  echo "No se pudo obtener la dirección IP. Abortando."
  exit 1
fi

# Crear directorio si no existe
mkdir -p "\$CERT_DIR"
chown luicasad:2023_barcelona "\$CERT_DIR"

# Generar certificado
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "\$KEY_FILE" -out "\$CRT_FILE" \
  -subj "/C=ES/ST=Catalonia/L=Barcelona/O=42barcelona/CN=\$IP"

chown luicasad:2023_barcelona "\$KEY_FILE"
chown luicasad:2023_barcelona "\$CRT_FILE"

echo "Certificado SSL generado para IP: \$IP"
EOF

# Asegurar permisos de ejecución
chmod +x /etc/local.d/generate_cert.start


echo "Archivo /etc/local.d/generate_cert.start creado correctamente."

rc-update add local default
