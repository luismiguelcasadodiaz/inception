#!/bin/sh
set -e
# Function to run a command as a specific user
# $* ==> The parameters are treated as a single string, separated by spaces.
# $@ ==> Treats each parameter as a separate word (argument)
run_as_user() {
    local user="$1"
    shift
    if [ "$(id -u)" -eq "$(id -u "$user")" ]; then
        # Already the correct user, run directly
        echo "$@"
        "$@"
    else
        # Switch user using su
        echo "su - $user -c \"$*\""
        su - "$user" -c "$*"
    fi
}
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Si mariadb-install-db debe existir el directorio
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing MariaDB data directory..."
    # Explicitly run as root
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    if [ $? -ne 0 ]; then
        echo "Error initializing MariaDB data directory."
        exit 1
    fi
    echo "1.-MariaDB data directory initialized."

    echo "2.-exec /usr/bin/mariadbd --datadir=/var/lib/mysql $@"
    exec su - mysql -s /bin/sh -c "/usr/bin/mariadbd --datadir=/var/lib/mysql \"\$@\""
else
    echo "exec /usr/bin/mariadbd --datadir=/var/lib/mysql $@"
    cat /etc/my.cnf.d/mariadb-server.cnf
    exec su - mysql -s /bin/sh -c "/usr/bin/mariadbd --datadir=/var/lib/mysql \"\$@\""
fi

