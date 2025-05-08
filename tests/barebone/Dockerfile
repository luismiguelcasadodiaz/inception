# each RUN command is a docker layer.
# gather in one RUN related commands to reduce the number of layer and consquently image size
# First RUN less frequently changing commands
FROM alpine:3.21.3

# set -ex 
#-e (errexit): This option tells the shell to immediately exit if a command exits 
# with a non-zero status (indicating an error). 
# Without this, even if a command fails during the Docker image build, 
# the subsequent commands might still run, potentially leading to a broken image without 
# you realizing it until later. Using -e helps catch errors early in the build process.
#
#-x (xtrace): This option causes the shell to print each command before executing it, 
# preceded by a + sign. This can be incredibly helpful for debugging your Dockerfile. 
# When you're building an image and something goes wrong, 
# the output from set -x shows you exactly which command was being run
# at the time of the failure.

# --no-cache prevents apk from saving the list of available packages brought by apk update
# saving image size in 2.377 MB
# -rw-r--r--    1 root     root      475.6K May  8 08:36 APKINDEX.36c0efc6.tar.gz
# -rw-r--r--    1 root     root        1.9M May  8 08:36 APKINDEX.e33e93f4.tar.gz

# apk add verifies package signatures
# apk add also mariadb-client to iteract wiht the server during 
# configuration
# apk creates group and user "mysql' wiht GID(101) and UID(100)
# user mysql home directory is /var/lib/mysql with ownership mysql:mysql
# user mysql(100) shell is /sbin/nologin, to avoid logins wiht this user.

RUN set -ex && \
    apk update && \
    apk add --no-cache mariadb mariadb-client && \
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql


VOLUME /var/lib/mysql

#otherwise executed as root
USER mysql 
ENTRYPOINT ["/usr/bin/mariadbd", "--datadir=/var/lib/mysql"]



