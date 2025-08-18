
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

# Implicit user add and folder creation

This Dockerfile command implicitly adds mysql user
```Dockerfile
RUN apk apk add --no-cache mariadb mariadb-client
```


| FROM alpine:3.21.3  | FROM alpine:3.21.3 |
|--------|--------|
||RUN apk add mariadb mariadb-client|
|`root:x:0:0:root:/root:/bin/sh`<br>`bin:x:1:1:bin:/bin:/sbin/nologin`<br>`daemon:x:2:2:daemon:/sbin:/sbin/nologin`<br>`lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin`<br>`sync:x:5:0:sync:/sbin:/bin/sync`<br>`shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown`<br>`halt:x:7:0:halt:/sbin:/sbin/halt`<br>`mail:x:8:12:mail:/var/mail:/sbin/nologin`<br>`news:x:9:13:news:/usr/lib/news:/sbin/nologin`<br>`uucp:x:10:14:uucp:/var/spool/uucppublic:/sbin/nologin`<br>`cron:x:16:16:cron:/var/spool/cron:/sbin/nologin`<br>`ftp:x:21:21::/var/lib/ftp:/sbin/nologin`<br>`sshd:x:22:22:sshd:/dev/null:/sbin/nologin`<br>`games:x:35:35:games:/usr/games:/sbin/nologin`<br>`ntp:x:123:123:NTP:/var/empty:/sbin/nologin`<br>`guest:x:405:100:guest:/dev/null:/sbin/nologin`<br>`nobody:x:65534:65534:nobody:/:/sbin/nologin`|`root:x:0:0:root:/root:/bin/sh` <br> `bin:x:1:1:bin:/bin:/sbin/nologin`<br>`daemon:x:2:2:daemon:/sbin:/sbin/nologin`<br>`lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin`<br>`sync:x:5:0:sync:/sbin:/bin/sync`<br>`shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown`<br>`halt:x:7:0:halt:/sbin:/sbin/halt`<br>`mail:x:8:12:mail:/var/mail:/sbin/nologin`<br>`news:x:9:13:news:/usr/lib/news:/sbin/nologin`<br>`uucp:x:10:14:uucp:/var/spool/uucppublic:/sbin/nologin`<br>`cron:x:16:16:cron:/var/spool/cron:/sbin/nologin`<br>`ftp:x:21:21::/var/lib/ftp:/sbin/nologin`<br>`sshd:x:22:22:sshd:/dev/null:/sbin/nologin`<br>`games:x:35:35:games:/usr/games:/sbin/nologin`<br>`ntp:x:123:123:NTP:/var/empty:/sbin/nologin`<br>`guest:x:405:100:guest:/dev/null:/sbin/nologin`<br>`nobody:x:65534:65534:nobody:/:/sbin/nologin` <br>🟩 mysql\:x\:100\:101:mysql:/var/lib/mysql:/sbin/nologin|
|/var/lib/misc|/var/lib/misc <br>🟩  /var/lib/mysql|

The fact that mysql user has no login, brought some headache trying to run Maria's daemond as mysql user.

```bash
exec su - mysql -s /bin/sh -c "/usr/bin/mariadbd --datadir=/var/lib/mysql \"\$@\""
```
was the solution. -s flags adds a shell to nologin users

# mariadb-install-db

```Dockerfile
RUN apk add --no-cache mariadb mariadb-client && mariadb-install-db
```
Installs it in `./data` folder with `root` ownership


```bash
/ # ls -al data
total 141768
drwx------    6 root     root          4096 May  9 07:03 .
drwxr-xr-x    1 root     root          4096 May  9 07:05 ..
-rw-rw----    1 root     root        417792 May  9 07:03 aria_log.00000001
-rw-rw----    1 root     root            52 May  9 07:03 aria_log_control
-rw-r-----    1 root     root           782 May  9 07:03 ib_buffer_pool
-rw-rw----    1 root     root     100663296 May  9 07:03 ib_logfile0
-rw-rw----    1 root     root      12582912 May  9 07:03 ibdata1
-rw-r--r--    1 root     root            14 May  9 07:03 mariadb_upgrade_info
drwx------    2 root     root          4096 May  9 07:03 mysql
drwx------    2 root     root          4096 May  9 07:03 performance_schema
drwx------    2 root     root         12288 May  9 07:03 sys
drwx------    2 root     root          4096 May  9 07:03 test
-rw-rw----    1 root     root      10485760 May  9 07:03 undo001
-rw-rw----    1 root     root      10485760 May  9 07:03 undo002
-rw-rw----    1 root     root      10485760 May  9 07:03 undo003


```
This is the reason for `--user` and `--datadir` arguments to mariadb-install-db
```Dockerfile
RUN apk add --no-cache mariadb mariadb-client && mariadb-install-db --user=mysql --datadir=/var/lib/mysql
```

# mariadbd default's folder

I founded it running inside container shell this command
```bash
apk info -L mariadb | grep mariadbd
```

# mariadb-server.cnf default status
     
```cnf                                                                                                                                        
# These groups are read by MariaDB server.                                                                                                      
# Use it for options that only the server (but not clients) should see                                                                          
                                                                                                                                                
# this is read by the standalone daemon and embedded servers                                                                                    
[server]                                                                                                                                        
                                                                                                                                                
# this is only for the mysqld standalone daemon                                                                                                 
[mysqld]                                                                                                                                        
skip-networking                                                                                                                                 
                                                                                                                                                
# Galera-related settings                                                                                                                       
[galera]                                                                                                                                        
# Mandatory settings                                                                                                                            
#wsrep_on=ON                                                                                                                                    
#wsrep_provider=                                                                                                                                
#wsrep_cluster_address=                                                                                                                         
#binlog_format=row                                                                                                                              
#default_storage_engine=InnoDB                                                                                                                  
#innodb_autoinc_lock_mode=2                                                                                                                     
#                                                                                                                                               
# Allow server to accept connections on all interfaces.                                                                                         
#                                                                                                                                               
#bind-address=0.0.0.0                                                                                                                           
#                                                                                                                                               
# Optional setting                                                                                                                              
#wsrep_slave_threads=1                                                                                                                          
#innodb_flush_log_at_trx_commit=0                                                                                                               
                                                                                                                                                
# this is only for embedded server                                                                                                              
[embedded]                                                                                                                                      
                                                                                                                                                
# This group is only read by MariaDB servers, not by MySQL.                                                                                     
# If you use the same .cnf file for MySQL and MariaDB,                                                                                          
# you can put MariaDB-only options here                                                                                                         
[mariadb]                                                                                                                                       
                                                                                                                                                
# This group is only read by MariaDB-10.5 servers.                                                                                              
# If you use the same .cnf file for MariaDB of different versions,                                                                              
# use this group for options that older servers don't understand                                                                                
[mariadb-10.5]     

```

Mariadb, in this dbcontainer will be accesed from contentserver. I must comment `skip-networking`





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

