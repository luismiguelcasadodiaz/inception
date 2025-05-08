#!/bin/sh
set -e

# Check if the data directory is empty (first run)
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    echo "MariaDB data directory initialized."

    # Set root password if MYSQL_ROOT_PASSWORD is set
    if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
        echo "Setting root password..."
        mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
        mariadb -u root -e "FLUSH PRIVILEGES;"
        echo "Root password set."
    fi
fi

# Start the MariaDB server
exec /usr/sbin/mariadbd --datadir=/var/lib/mysql "$@"