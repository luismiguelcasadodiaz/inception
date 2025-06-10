
# Configuration files

MariaDB reads configuration files in a specific order, and settings in **later files can override those in earlier ones**.

+ A.- Global Configuration Files (System-Wide):

    + 1.- /etc/mysql/mariadb.cnf (or /etc/my.cnf): This is often the primary global configuration file. The exact path might vary slightly based on the Linux distribution (e.g., /etc/mysql/my.cnf on Debian/Ubuntu).

    + 2.- /etc/mysql/conf.d/*.cnf: Any files ending with .cnf in this directory are read in alphabetical order after the main global configuration file. This allows for modular configuration.

    + 3.- /etc/mysql/mariadb.conf.d/*.cnf: Similar to the above, but these are typically intended for MariaDB-specific configurations and are also read in alphabetical order.

+ B.- User-Specific Configuration File:

    + 4.- ~/.my.cnf (or $HOME/.my.cnf): This is the user-specific configuration file in the home directory of the user running the MariaDB client or server. Settings here will override the global settings for that specific user.

+ C.- Command-Line Arguments:

    + 5.- /Command-line arguments: Options passed directly when starting the mariadbd server or the mariadb client will override any settings in the configuration files.


# Allow network connections


```sh
sed -i -e '/^skip-networking/ s/^skip-networking/#skip-networking/' /etc/my.cnf.d/mariadb-server.cnf
```
# lists current users un mariadb server

MariaDB [(none)]> SELECT Host, User, password FROM mysql.user;


| Host         | User        | Password |
|--------------|-------------|----------|
| localhost    | mariadb.sys |          |
| localhost    | root        | invalid  |
| localhost    | mysql       | invalid  |
|              | PUBLIC      |          |
| localhost    |             |          |
| c8d495df1576 |             |          |





# accesing as root from other containers


GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.1.1' IDENTIFIED BY 'your_root_password';
```sh
MariaDB [(none)]> SELECT Host, User, password FROM mysql.user\g
+------------------------------------+-------------+-------------------------------------------+
| Host                               | User        | Password                                  |
+------------------------------------+-------------+-------------------------------------------+
| localhost                          | mariadb.sys |                                           |
| localhost                          | root        | invalid                                   |
| localhost                          | mysql       | invalid                                   |
|                                    | PUBLIC      |                                           |
| localhost                          |             |                                           |
| 68a573832cf0                       |             |                                           |
| tirame_cli.inception_inception_net | root        | *B688F3445F289C2E7E1B3ED123BF87066EA672A0 |
| 192.168.1.14                       | root        | *B688F3445F289C2E7E1B3ED123BF87066EA672A0 |
+------------------------------------+-------------+-------------------------------------------+
```


# lists current users in mariadb server
```sh
MariaDB [(none)]> SELECT DISTINCT user FROM mysql.global_priv;
+-------------+
| user        |
+-------------+
| PUBLIC      |
| root        |
|             |
| mariadb.sys |
| mysql       |
+-------------+
```

