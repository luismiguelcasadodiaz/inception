# MARIA DATABASE CONFIGURATION


Default options are read from the following files in the given order:

/etc/my.cnf /etc/mysql/my.cnf ~/.my.cnf 




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

