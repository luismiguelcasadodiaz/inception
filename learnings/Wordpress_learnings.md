
# wp-config.php

If `wp-config.php` does not exist, Wordpress starts with a form asking manual typping for:

+ DATABASE_NAME
+ USER_NAME
+ PASSWRD
+ DATABASE_HOST
+ TABLE_PREFIX

Inception requires an automatic setup. So we must create a `wp-config.php` making one copy from `/www/wp-config-sample.php` and editting this lines

```conf

define( 'DB_HOST', 'localhost' ); 
define( 'DB_NAME', 'database_name_here' );
define( 'DB_USER', 'username_here' );  
define( 'DB_PASSWORD', 'password_here' );
```
One `sed` command assists us with this replacements
 
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

To hide this information, let's use some built-in php functions:

+ **getenv()**: Returns the value as a string, or false if the variable does not exist.

```sh
$user = getenv('DBSERVER_MSQL_USER');
```


+ **file_get_contents()**: Returns file content as a string or false on error. Make sure the file is readable by the PHP process. ery common for reading secrets, JSON, or config files

```sh
$password = file_get_contents('/run/secrets/db_password');
```



+ **trim()**:Removes whitespace or other characters from the beginning and end of a string. Useful when reading from files where trailing \n or whitespace may appear.
```sh
$cleaned = trim("  example\n");
```

Change `sed` to use the built-in funcion like this

```sh
sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', getenv('DATABASE_HOST') );/" $CONFIG_FILE                    
sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', getenv('DATABASE_NAME') );/" $CONFIG_FILE         
sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', getenv('DBSERVER_MSQL_USER') );/" $CONFIG_FILE         
sed -i "s|define( 'DB_PASSWORD', 'password_here' );|define( 'DB_PASSWORD', trim(file_get_contents('/tmp/db_password')) );|" $CONFIG_FILE     
```

Note that last `search` commnad for `sed` has pipe (`|`) instead of slash(`/`) as a delimiter cause  `$DBSERVER_MSQL_PASSWORD_FILE` is a path

and you will get

```conf
define( 'DB_NAME', getenv('DATABASE_NAME') );
define( 'DB_USER', getenv('DBSERVER_MSQL_USER') );
define( 'DB_PASSWORD', trim(file_get_contents('/tmp/db_password')) );
define( 'DB_HOST', getenv('DATABASE_HOST') );     
```
An additional problem arises with the permissions to read the secret.
Docker creates a READ ONLY folder for the secrets owned by root and the group x (104, 105, etc, not a fix one choosen by swarm)
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
This is why inside the entrypoint script I copy the secret to an editable folder to change ownership and permissions

```sh
cp $DBSERVER_MSQL_PASSWORD_FILE /tmp/db_password
chown root:nginx /tmp/db_password
chmod 640 /tmp/db_password
```
# wp-admin/install.php

It is the first script executed by wordpress. That implies a manual intervention of user we want to avoid.

Wordpress has a utility that automatices the installation process. wp-cli.

```Dockerfile
RUN apk add --no-cache wget \ # Install wget to download the phar file
    && wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar
```
