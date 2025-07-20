#!/bin/sh
set -ex

if [ ! -f /run/secrets/dbserver_root_password ]; then
  echo "Secret not found — skipping healthcheck for now"
  exit 0
fi

# Read the root password from the mounted secret file
ROOT_PASSWORD=$(cat /run/secrets/dbserver_root_password)
echo "ROOT_PASSWORD=$ROOT_PASSWORD"

# Ping MariaDB using the retrieved password
mariadb-admin ping -u root --password="$ROOT_PASSWORD" -h localhost

# If mariadb-admin ping exits with 0, the healthcheck passes
exit 0