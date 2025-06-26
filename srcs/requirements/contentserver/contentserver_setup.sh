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
# Inside entrypoint or /etc/local.d/secret_copy.start
cp $DBSERVER_MSQL_PASSWORD_FILE /tmp/db_password
chown root:nginx /tmp/db_password
chmod 640 /tmp/db_password

if [ -f "$CONFIG_FILE" ]; then
    echo "File already exists: $CONFIG_FILE"
    php-fpm84 -F
else
    echo "Installing Wordpress. File does not exist: $CONFIG_FILE"
    # Navigate to /www
    cd /www
    rm -rf *
    # Download Wordress
    wget https://wordpress.org/latest.tar.gz
    # Unpack it
    tar -xzf latest.tar.gz
    # Move all from    /www/wordpress/*  to /www
    mv wordpress/* /www/
    # Remove the empty wordpress directory
    rm -rf wordpress
    # Clean up downloaded archive
    rm latest.tar.gz
    # Recover index.php
    cp /opt/index.php .
    # Duplicate wp-config.php
    cp "$SAMPLE_FILE" "$CONFIG_FILE"
    # Modify define sentences  inside wp-config.php
    sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', getenv('DATABASE_HOST') );/" $CONFIG_FILE                    
    sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', getenv('DATABASE_NAME') );/" $CONFIG_FILE         
    sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', getenv('DBSERVER_MSQL_USER') );/" $CONFIG_FILE         
    sed -i "s|define( 'DB_PASSWORD', 'password_here' );|define( 'DB_PASSWORD', trim(file_get_contents('/tmp/db_password')) );|" $CONFIG_FILE         
    php-fpm84 -F
fi


