
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
sed -i "s|define( 'DB_PASSWORD', 'password_here' );|define( 'DB_PASSWORD', trim(file_get_contents('$DBSERVER_MSQL_PASSWORD_FILE')) );|" $CONFIG_FILE         
```

Note that last `search` commnad for `sed` has pipe (`|`) instead of slash(`/`) as a delimiter cause  `$DBSERVER_MSQL_PASSWORD_FILE` is a path

and you will get

```conf
define( 'DB_NAME', getenv('DATABASE_NAME') );
define( 'DB_USER', getenv('DBSERVER_MSQL_USER') );
define( 'DB_PASSWORD', trim(file_get_contents('/run/secrets/dbserver_msql_password')) );
define( 'DB_HOST', getenv('DATABASE_HOST') );     
```