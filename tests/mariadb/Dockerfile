# each RUN command is a docker layer.
# gather in one RUN related commands to reduce the number of layer and consquently image size
# First RUN less frequently changing commands
FROM alpine:3.21.3
# apk add verifies package signatures
RUN set -ex && \
    apk update && \
    apk add --no-cache gnupg mariadb mariadb-client



# # Creo el grupo mysql y el usuario mysql que agrego a ese grupo
# RUN groupadd -r mysql && useradd -r -g mysql mysql

# # https://bugs.debian.org/830696 (apt uses gpgv by default in newer releases, rather than gpg)
# RUN set -ex; \
# 	apt-get update; \
# 	if ! which gpg; then \
# 		apt-get install -y --no-install-recommends gnupg; \
# 	fi; \
# # Ubuntu includes "gnupg" (not "gnupg2", but still 2.x), but not dirmngr, and gnupg 2.x requires dirmngr
# # so, if we're not running gnupg 1.x, explicitly install dirmngr too
# 	if ! gpg --version | grep -q '^gpg (GnuPG) 1\.'; then \
# 		 apt-get install -y --no-install-recommends dirmngr; \
# 	fi; \
# 	rm -rf /var/lib/apt/lists/*

# # add gosu for easy step-down from root
# ENV GOSU_VERSION 1.10
# RUN set -ex; \
# 	\
# 	fetchDeps=' \
# 		ca-certificates \
# 		wget \
# 	'; \
# 	apt-get update; \
# 	apt-get install -y --no-install-recommends $fetchDeps; \
# 	rm -rf /var/lib/apt/lists/*; \
# 	\
# 	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
# 	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
# 	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
# 	\
# # verify the signature
# 	export GNUPGHOME="$(mktemp -d)"; \
# 	gpg --keyserver keyserver.ubuntu.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
# 	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
# 	command -v gpgconf > /dev/null && gpgconf --kill all || :; \
# 	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
# 	\
# 	chmod +x /usr/local/bin/gosu; \
# # verify that the binary works
# 	gosu nobody true; \
# 	\
# 	apt-get purge -y --auto-remove $fetchDeps

# RUN mkdir /docker-entrypoint-initdb.d

# # install "pwgen" for randomizing passwords
# # install "tzdata" for /usr/share/zoneinfo/
# RUN apt-get update && apt-get install -y --no-install-recommends \
# 		apt-transport-https ca-certificates \
# 		pwgen \
# 		tzdata \
# 	&& rm -rf /var/lib/apt/lists/*

# ENV GPG_KEYS \
# # Key fingerprint = 1993 69E5 404B D5FC 7D2F  E43B CBCB 082A 1BB9 43DB
# # MariaDB Package Signing Key <package-signing-key@mariadb.org>
# # for MariaDB 5.5
# 	199369E5404BD5FC7D2FE43BCBCB082A1BB943DB \
# # pub   rsa4096 2016-03-30 [SC]
# #         177F 4010 FE56 CA33 3630  0305 F165 6F24 C74C D1D8
# # uid           [ unknown] MariaDB Signing Key <signing-key@mariadb.org>
# # sub   rsa4096 2016-03-30 [E]
# # for MariaDB 10+
# 	177F4010FE56CA3336300305F1656F24C74CD1D8

# RUN set -ex; \
# 	export GNUPGHOME="$(mktemp -d)"; \
# 	for key in $GPG_KEYS; do \
# 		gpg --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
# 	done; \
# 	gpg --export $GPG_KEYS > /etc/apt/trusted.gpg.d/mariadb.gpg; \
# 	command -v gpgconf > /dev/null && gpgconf --kill all || :; \
# 	rm -r "$GNUPGHOME"; \
# 	apt-key list

# # bashbrew-architectures:%%ARCHES%%
# ENV MARIADB_MAJOR %%MARIADB_MAJOR%%
# ENV MARIADB_VERSION %%MARIADB_VERSION%%

RUN set -e;\
	echo "deb http://downloads.mariadb.com/MariaDB/mariadb-$MARIADB_MAJOR/repo/ubuntu %%SUITE%% main" > /etc/apt/sources.list.d/mariadb.list; \
	{ \
		echo 'Package: *'; \
		echo 'Pin: release o=MariaDB'; \
		echo 'Pin-Priority: 999'; \
	} > /etc/apt/preferences.d/mariadb
# add repository pinning to make sure dependencies from this MariaDB repo are preferred over Debian dependencies
#  libmariadbclient18 : Depends: libmysqlclient18 (= 5.5.42+maria-1~wheezy) but 5.5.43-0+deb7u1 is to be installed

# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
# also, we set debconf keys to make APT a little quieter
RUN set -ex; \
	{ \
		echo "mariadb-server-$MARIADB_MAJOR" mysql-server/root_password password 'unused'; \
		echo "mariadb-server-$MARIADB_MAJOR" mysql-server/root_password_again password 'unused'; \
	} | debconf-set-selections; \
	backupPackage='%%BACKUP_PACKAGE%%'; \
	apt-get update; \
	apt-get install -y \
		"mariadb-server=$MARIADB_VERSION" \
		$backupPackage \
		socat \
	; \
	rm -rf /var/lib/apt/lists/*; \
# comment out any "user" entires in the MySQL config ("docker-entrypoint.sh" or "--user" will handle user switching)
	sed -ri 's/^user\s/#&/' /etc/mysql/my.cnf /etc/mysql/conf.d/*; \
# purge and re-create /var/lib/mysql with appropriate ownership
	rm -rf /var/lib/mysql; \
	mkdir -p /var/lib/mysql /var/run/mysqld; \
	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld; \
# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
	chmod 777 /var/run/mysqld; \
# comment out a few problematic configuration values
	find /etc/mysql/ -name '*.cnf' -print0 \
		| xargs -0 grep -lZE '^(bind-address|log)' \
		| xargs -rt -0 sed -Ei 's/^(bind-address|log)/#&/'; \
# don't reverse lookup hostnames, they are usually another container
	echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf

VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]



COPY dbserver_setup.sh /dbserver_setup.sh
RUN chmod +x /dbserver_setup.sh && /dbserver_setup.sh
EXPOSE 3306