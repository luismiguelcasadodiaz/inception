#!/bin/sh
set -ex

# Function to read secret from file
read_secret() {
    local file="$1"
    if [ -f "$file" ]; then
        cat "$file"
    fi
}


CONFIG_FILE="/www/wp-config.php"
SAMPLE_FILE="/www/wp-config-sample.php"
DBSERVER_MSQL_PASSWORD=$(read_secret "$DBSERVER_MSQL_PASSWORD_FILE")


echo "DB_HOST:>$DATABASE_HOST<"
echo "DB_NAME:>$DATABASE_NAME<"
echo "DB_USER:>$DBSERVER_MSQL_USER<"
echo "DB_PASSWORD:>$DBSERVER_MSQL_PASSWORD<"

if [ -f "$CONFIG_FILE" ]; then
    echo "File already exists: $CONFIG_FILE"
    exit 0
else
    echo "Creating $CONFIG_FILE from sample..."
    cp "$SAMPLE_FILE" "$CONFIG_FILE" || {
        echo "Failed to create $CONFIG_FILE"
        exit 1
    }
    sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', '$DATABASE_HOST' );/" $CONFIG_FILE                    
    sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', '$DATABASE_NAME' );/" $CONFIG_FILE         
    sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', '$DBSERVER_MSQL_USER' );/" $CONFIG_FILE         
    sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '$DBSERVER_MSQL_PASSWORD' );/" $CONFIG_FILE         

fi
