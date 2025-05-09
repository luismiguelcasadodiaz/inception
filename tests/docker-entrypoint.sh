#!/bin/sh
set -e

# Si mariadb-install-db debe existir el directorio
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    echo "MariaDB data directory initialized."
else
    echo "MariaDB server ejecutando"
fi

