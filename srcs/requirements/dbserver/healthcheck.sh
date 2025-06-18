#!/bin/sh
set -ex

# Read the root password from the mounted secret file
ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Ping MariaDB using the retrieved password
mariadb-admin ping -u root --password="$ROOT_PASSWORD" -h localhost

# If mariadb-admin ping exits with 0, the healthcheck passes
exit 0