#!/bin/sh
set -ex

# Function to read secret from file
read_secret() {
    local file="$1"
    if [ -f "$file" ]; then
        cat "$file"
    fi
}

DBSERVER_MSQL_PASSWORD=$(read_secret "$DBSERVER_MSQL_PASSWORD_FILE")
echo "msql pass:>$DBSERVER_MSQL_PASSWORD<"

exec su - mysql -s /bin/sh -c "/usr/bin/mariadb -u mysql -p$DBSERVER_MSQL_PASSWORD -h dbserver"
