FROM alpine:latest
LABEL org.label-schema.schema-version = "1.0"
LABEL org.label-schema.maintainer="Luis Miguel Casado Díaz <luicasad@student.42barcelona.com>"
LABEL org.label-schema.version="11.4.5"
LABEL org.label-schema.description="A Docker image running MariaDB server on Alpine Linux."
LABEL org.label-schema.url="[https://github.com/luismiguelcasadodiaz/inception]"
LABEL org. label-schema.date="May 2025"


RUN apk add --no-cache mariadb mariadb-client && mariadb-install-db --user=mysql --datadir=/var/lib/mysql
#USER mysql
CMD ["/bin/sh"]


# -rw-r--r--    1 root     root      475.6K May  8 08:36 APKINDEX.36c0efc6.tar.gz
# -rw-r--r--    1 root     root        1.9M May  8 08:36 APKINDEX.e33e93f4.tar.gz