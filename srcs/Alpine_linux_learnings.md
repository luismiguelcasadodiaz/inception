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

