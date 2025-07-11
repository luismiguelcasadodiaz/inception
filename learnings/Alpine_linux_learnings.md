# Version

I use an Alpine linux version with an slimmed down kernel. Optimized for virtual systems.[Named virtual ](https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-virt-3.21.3-x86_64.iso)

It is a volatil version designe to exist only in RAM. Running setup you MUST make file sustem persistent

# Login
User root has no password. FIX this at setup.

# setup-alpine
This is the script to configure Alpine linux
+ select keyboar map: us us ---> to fit with 42 Mac keyboards
+ select hostname : localhost [default]
+ Interface:
    + to initialize: eth0 [default]
    + Ip address for eth0: dhcp [default]
    + any manual network configuration: n [default]

+ Root Password:
+ TimeZone : Europe Madrid
+ Proxy : none [default]
+ Network Time Protocol : chrony [default]
+ APK Mirror
    + Enable community repositories (c). Required to download Docker, Git, etc...
    + Find and use fastest mirror (f) --> mirror.raiolanetworks.net Lugo Spain  NUMBER 84
+ user : no  [default] --> I will create it later with the UID/GID luicasad has in hostmachine
+ ssh
    + server : openssh [default]
    + root login prohibit-password [default]
    + root key : nono [default]
+ Disk & Install
    + disk to use : sda
    + how use it  : sys  --> i want sda become a system disks
    + Erase sda disk and continue : y


# /etc/fstab

Configure automount the shared folder between host machine and virtual machine. Add this line

```bash
inception_host	/home/luicasad/inception_host	vboxsf	defaults	0	0
or
inception  /home/luicasad vboxsf user,uid=101177,gid=4223,rw,auto 0 0

```

🚫
You're absolutely right — and this is a known limitation of vboxsf (VirtualBox Shared Folders):

Even with uid= and gid= options in /etc/fstab, vboxsf mounts are always owned by root:vboxsf, and Alpine (or other Linux guests) can't force change that ownership.

This is not a bug in Alpine, but a design limitation of the VirtualBox shared folder driver.

# add new user

I want that my user luicasad in the virtual machine has the same uid/gid that the ones I have in my host machine. This will help me later to push changes from virtual machine to my repositories

```bash
id luicasad
uid=101177(luicasad) gid=4223(2023_barcelona) groups=204(_developer),4223(2023_barcelona)
```


```sh
addgroup -g 4223 2023_barcelona
adduser -u 101177 -G 2023_barcelona -D luicasad
adduser luicasad docker
```

# install required packages

apk add git
apk add make
apk add jq
apk add docker
apk add docker-compose






# docker wakes up at boot time
```sh
rc-update add docker boot
rd-service docker start
```

# init swarm service for secrets

```sh
docker swarm init
```

# allow my user to run docker
```sh
adduser luicasad docker
```

# keys

Copy you id_rsa key from your 42 school home directory to work wiht the delivery repository

# /bin/sh



On Alpine Linux, /bin/sh is usually a POSIX shell (ash), which does not support ${!var}, a `indirect parameter expansion`. 
The indirect parameter expansion is a bash feature.

My db container entrypoint script gave me an error `line 77: syntax error: bad substitution`


```sh
set_mysql_password() {
    local username="$1"
    local file_var="$2"
    local env_var="$3"

    local password=$(read_secret "${!file_var}")  <<======>>
    echo "user =$username"
    echo "file =$file_var"
    echo "envi =$env_var"
    echo "pass =$password"
```

i solved it like this

```sh
    local password=$(read_secret "$file_var")
```

# configure /etc/hosts

Inception subject says: 

+ You must configure your **domain name to point to your local IP address**. This domain name must be luicasad.42.fr.

Despite that Alpine Linux has a `setup-hostname` command, the result does not affects /etc/hosts

```bash
/ # setup-hostname 
Enter system hostname (fully qualified form, e.g. 'foo.example.org') [luicasad.42.fr] 
/ # cat /etc/hosts
127.0.0.1	luicasad.42barcelona.com luicasad localhost.localdomain localhost
::1		localhost localhost.localdomain
/ # 
```

Additionally the network interface i work with in the Oracle VirtualBox is bridge, so my VM gets its IP dynamically from 42's DHCP.

I ask at booting time to update `/etc/hosts` with the current ip running `/etc/local.d/update_hosts.start`

# SQL syntax and /bin/sh

Blending enviroment variables with SQL sentences created at runtime was not straight.

My **first approach** inside dbserver's  `docker-entrypoint.sh` was:

```sh
mariadb -u root -e "CREATE DATABASE IF NOT EXISTS '$DATABASE_NAME';" -S /run/mysqld/mysqld.sock
```

That expanded and behavied like this
```sh 
mariadb -u root -e 'CREATE DATABASE IF NOT EXISTS '"'"'WORDPRESS'"'"';' -S /run/mysqld/mysqld.sock
--------------
CREATE DATABASE IF NOT EXISTS 'WORDPRESS'
--------------
ERROR 1064 (42000) at line 1: You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near ''WORDPRESS'' at line 1
```
Using single quotes ('WORDPRESS') makes MariaDB interpret "WORDPRESS" as a string literal, not a database name. I cannot create a database with a string literal as its name.

In SQL:

+ Single quotes (') are used to delimit string literals (e.g., 'hello world'). You use these for data values.

+ Backticks (`) are used to delimit identifiers (like database names, table names, column names) when those identifiers contain special characters, spaces, or are reserved keywords.

My **second approach** was


```sh
mariadb -u root -e "CREATE DATABASE IF NOT EXISTS `$DATABASE_NAME`;" -S /run/mysqld/mysqld.sock
```

and the error inside dbserver's  `docker-entrypoint.sh` changed to the error message:

```sh
/usr/local/sbin/docker-entrypoint.sh: line 60: WORDPRESS: not found
+ mariadb -u root -e 'CREATE DATABASE IF NOT EXISTS ;' -S /run/mysqld/mysqld.sock
```


The reason behind this change was the fact that in shell scripting, when you wrap a command in backticks `command`, the shell:
+ Executes the command inside the backticks.
+ Captures the output of that command.
+ Substitutes the backtick expression with that output.

in such a way that 
```sh
echo "Today is: `date`"
```
becomes 
```sh
Today is: Fri Jun 28 12:34:56 UTC 2024
```

There is not `wordpress` command in `/bin/sh`'s path


The Solution: Escaping the Backticks for Literal Use

You need the backticks to be passed literally to the mariadb command for SQL, not interpreted by the shell for command substitution. To do this, you must escape the backticks with a backslash when they are inside double quotes.



```sh
mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`$DATABASE_NAME\`;" -S /run/mysqld/mysqld.sock
```