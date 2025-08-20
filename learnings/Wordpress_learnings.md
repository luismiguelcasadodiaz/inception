
# wp-config.php

If `wp-config.php` does not exist, WordPress starts with a form asking for manual typing:

+ DATABASE_NAME
+ USER_NAME
+ PASSWRD
+ DATABASE_HOST
+ TABLE_PREFIX

Inception requires an automatic setup. So we must create a `wp-config.php`, making one copy from `/www/wp-config-sample.php` and editing these lines

```conf

define( 'DB_HOST', 'localhost' ); 
define( 'DB_NAME', 'database_name_here' );
define( 'DB_USER', 'username_here' );  
define( 'DB_PASSWORD', 'password_here' );
```
One `sed` command assists us with these replacements
 
```bash
   sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', '$DATABASE_HOST' );/" $CONFIG_FILE                    
```

But the result would be 
```conf

define( 'DB_NAME', WORDPRESS' );
define( 'DB_USER', 'mysql' );
define( 'DB_PASSWORD', 'jaja_msql_jaja' );
define( 'DB_HOST', '192.168.1.2' ); 
```

To hide this information, let's use some built-in PHP functions:

+ **getenv()**: Returns the value as a string, or false if the variable does not exist.

```sh
$user = getenv('DBSERVER_MSQL_USER');
```


+ **file_get_contents()**: Returns file content as a string or false on error. Make sure the file is readable by the PHP process. ery common for reading secrets, JSON, or config files

```sh
$password = file_get_contents('/run/secrets/db_password');
```



+ **trim()**: Removes whitespace or other characters from the beginning and end of a string. Useful when reading from files where trailing \n or whitespace may appear.
```sh
$cleaned = trim("  example\n");
```

Change `sed` to use the built-in function like this

```sh
sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', getenv('DATABASE_HOST') );/" $CONFIG_FILE                    
sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', getenv('DATABASE_NAME') );/" $CONFIG_FILE         
sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', getenv('DBSERVER_MSQL_USER') );/" $CONFIG_FILE         
sed -i "s|define( 'DB_PASSWORD', 'password_here' );|define( 'DB_PASSWORD', trim(file_get_contents('/tmp/db_password')) );|" $CONFIG_FILE     
```

Note that the last `search` command for `sed` has a pipe (`|`) instead of a slash(`/`) as a delimiter cause  `$DBSERVER_MSQL_PASSWORD_FILE` is a path

And you will get

```conf
define( 'DB_NAME', getenv('DATABASE_NAME') );
define( 'DB_USER', getenv('DBSERVER_MSQL_USER') );
define( 'DB_PASSWORD', trim(file_get_contents('/tmp/db_password')) );
define( 'DB_HOST', getenv('DATABASE_HOST') );     
```
An additional problem arises with the permissions to read the secret.
Docker creates a READ-ONLY folder for the secrets owned by root and the group x (104, 105, etc, not a fixed one chosen by swarm)
php-fpm, running as nginx, can not read the secret


```sh
/ # ls -al /run/secrets/
total 20
drwxr-xr-x    2 root     root          4096 Jun 26 09:31 .
drwxr-xr-x    1 root     root          4096 Jun 26 09:31 ..
-rwxrwx---    1 root     104              9 Jun 23 06:29 contentserver_root_password
-rwxrwx---    1 root     104              8 Jun 23 06:29 contentserver_user_password
-rwxrwx---    1 root     104             14 May 13 10:38 dbserver_msql_password
```
This is why, inside the entrypoint script, I copy the secret to an editable folder to change ownership and permissions

```sh
cp $DBSERVER_MSQL_PASSWORD_FILE /tmp/db_password
chown root:nginx /tmp/db_password
chmod 640 /tmp/db_password
```
# wp-admin/install.php

This is the initial script triggered by WordPress during setup. It requires manual user intervention, which we aim to eliminate.

WordPress has a utility that automates the installation process. wp-cli.

```Dockerfile
RUN apk add --no-cache wget \ # Install wget to download the phar file
    && wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar
```


Alpine installs PHP, including the version in its name as a suffix (php84, php82, etc.). 
WP requires a PHP binary that has the literal `php` name.
I create a link inside the container at building time.

```sh
ln -s /usr/bin/php84 /usr/bin/php
```
