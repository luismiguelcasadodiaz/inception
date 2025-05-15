#!/bin/sh
set -e

# Function to read secret from file
read_secret() {
    local file="$1"
    if [ -f "$file" ]; then
        cat "$file"
    fi
}

# Function to read and set a MariaDB user password from secret file or env variable
set_mysql_password() {
    local username="$1"
    local file_var="$2"
    local env_var="$3"

    local password=$(read_secret "${!file_var}")

    if [ -n "$password" ]; then
        echo "Setting password for user '$username' from secret file..."
    elif [ -n "${!env_var}" ]; then
        echo "Warning: Using $env_var environment variable (less secure)."
        password="${!env_var}"
        echo "Setting password for user '$username' from environment variable..."
    else
        echo "No password provided for user '$username'. Skipping."
        return
    fi

    if [ "$username" = "root" ]; then
        mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$password';"
    else
        mariadb -u root -e "CREATE USER IF NOT EXISTS '$username'@'localhost' IDENTIFIED BY '$password';"
        mariadb -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$username'@'localhost';"
    fi

    mariadb -u root -e "FLUSH PRIVILEGES;"
    echo "Password set for user '$username'."
}

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Set root password if MYSQL_ROOT_PASSWORD_FILE is set
DBSERVER_ROOT_PASSWORD=$(read_secret "$DBSERVER_ROOT_PASSWORD_FILE")
DBSERVER_MSQL_PASSWORD=$(read_secret "$DBSERVER_MSQL_PASSWORD_FILE")
echo "root:>$DBSERVER_ROOT_PASSWORD<"
echo "msql:>$DBSERVER_MSQL_PASSWORD<"
# Si mariadb-install-db debe existir el directorio
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "0.-Initializing MariaDB data directory..."
    # Explicitly run as root
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    if [ $? -ne 0 ]; then
        echo "Error initializing MariaDB data directory."
        exit 1
    fi
    echo "1.-MariaDB data directory initialized."
    # Set passwords using the function
    set_mysql_password "root" "MYSQL_ROOT_PASSWORD_FILE" "MYSQL_ROOT_PASSWORD"
    set_mysql_password "mysql" "MYSQL_PASSWORD_FILE" "MYSQL_PASSWORD"

    echo "2.-exec /usr/bin/mariadbd --datadir=/var/lib/mysql"
    exec su - mysql -s /bin/sh -c "/usr/bin/mariadbd --datadir=/var/lib/mysql"
else
    echo "1.-exec /usr/bin/mariadbd --datadir=/var/lib/mysql"
    #cat /etc/my.cnf.d/mariadb-server.cnf
    exec su - mysql -s /bin/sh -c "/usr/bin/mariadbd --datadir=/var/lib/mysql"
    #exec /bin/sh
fi
