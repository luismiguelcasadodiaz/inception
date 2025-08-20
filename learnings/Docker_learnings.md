+ Each RUN command is a Docker layer.
+ Gather in one RUN related commands to reduce the number of layers and consequently image size
+ First RUN less frequently changing commands


# Secrets
Using Docker secrets requires initializing `docker swarm init`.

Secrets are not visible inside a Dockerfile. I discovered this through the dbserver's health check.

#### Create a secret from a file

```bash
docker secret create contentserver_root_password ./secrets/contentserver_root_password.txt
```

#### List current existing secrets
```bash
$ docker secret ls

ID                          NAME                          DRIVER    CREATED      UPDATED
pa9hsc30m99w331r7vn7c03k0   contentserver_root_password             2 days ago   2 days ago
u46we1f7i8s7lwp56r4o82945   contentserver_user_password             2 days ago   2 days ago
eyek645z2p0xjybrf2a2r0ard   dbserver_msql_password                  2 days ago   2 days ago
yzkl2g8r8nxmmrcp0om6chts9   dbserver_root_password                  2 days ago   2 days ago

```
#### remove one secret

```bash
docker secret rm dbserver_root_password 
```

#### Show details of one secret

```bash 
$ docker secret inspect contentserver_root_password 
[
    {
        "ID": "pa9hsc30m99w331r7vn7c03k0",
        "Version": {
            "Index": 13
        },
        "CreatedAt": "2025-05-13T10:17:10.322710711Z",
        "UpdatedAt": "2025-05-13T10:17:10.322710711Z",
        "Spec": {
            "Name": "contentserver_root_password",
            "Labels": {}
        }
    }
]
```

# Docker objects removal

Testing and testing make hard disk requirements grow and grow

To remove:
  - all stopped containers
  - all networks not used by at least one container
  - all images without at least one container associated with them
  - all build cache

We can use ...

```bash
docker system prune -a
```

# network
Docker automatically assigns the first IP in the subnet  as the gateway for internal routing. 
This means 192.168.1.1 is likely used by Docker itself, leading to the "Address already in use" error.

I defined a small subnet (/28), meaning only 14 usable addresses (from .1 to .14).

Reserved addresses:

+ 192.168.1.0 → Network address

+ 192.168.1.1 → Docker gateway

+ 192.168.1.15 → Broadcast address

Usable range: 192.168.1.2 → 192.168.1.14

# log sizes
 I aim to keep the virtual machine hard disk size small. This is why I limit log file size and number of log files to keep

```yaml

    logging:
      driver: "json-file" # Use json-file for easier access if you need to debug raw logs
      options:
        max-size: "25600" # Keep each log file up to 25600 Bytes or "25k"
        max-file: "3"   # Keep the 5 most recent log files      
```

To know where the log file is saved, we can use this command

```bash
docker inspect --format='{{.LogPath}}' inception-dbserver-1
/var/lib/docker/containers/d80c94c4acd52cd1996443de34c589cefab23340fa148ac44da67cc9a067dfe1/d80c94c4acd52cd1996443de34c589cefab23340fa148ac44da67cc9a067dfe1-json.log

```

# healthcheck

To ensure the dbserver is up and running before other containers start, a health check is available in the Dockerfile.

But Dockerfile does not have access to secrets. Dockerfile can read environmental variables defined in the `.env` file.

I do not want to duplicate where passwords are kept, so I created a healthcheck script for this purpose

```Dockerfile
#HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD mariadb-admin ping -u mysql --password="${DBSERVER_MSQL_PASSWORD}"-h localhost || exit 1
#  Dockerfile does not access secrets, only .env-defined variables. This is the reason to create a healthy check script.
HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD /usr/local/sbin/healthcheck.sh || exit 1

```

The Docker Compose files of dependent containers must have the instruction `depends_on`

```yaml
    depends_on:
      dbserver:
        condition: service_healthy  # Ensures database server is ready
```

# env_file

You can declare the `env_file` once in the root Compose file, and it will apply to services defined in that file only. 
It **won’t be automatically inherited by included Compose files** unless those files also specify it.
**Add** env_file: .env **inside each included Compose file** that uses the variables.


# Long container names

Docker Compose generates container and network names using this pattern:

```conf
<project_name>-<service_name>-<index>.<network_name>
```


Host 'inception-contentserver-1.inception_inception_net' is not allowed to connect to this MariaDB server

```bash
luicasad:~/inception$ docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED          STATUS                      PORTS                                       NAMES
eafa4d1a3023   webserver       "/usr/sbin/nginx -c …"   35 seconds ago   Up 11 seconds               0.0.0.0:443->443/tcp, :::443->443/tcp       inception-webserver-1
6833961d5c0e   contentserver   "/contentserver_setu…"   36 seconds ago   Up 22 seconds (healthy)     0.0.0.0:9000->9000/tcp, :::9000->9000/tcp   inception-contentserver-1
9b1135377e0f   dbserver        "/usr/local/sbin/doc…"   38 seconds ago   Up 33 seconds (healthy)     0.0.0.0:3306->3306/tcp, :::3306->3306/tcp   inception-dbserver-1
5dc881e03c0e   adminerserver   "lighttpd -D -f /etc…"   16 hours ago     Up 32 seconds (unhealthy)   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp     inception-adminerserver-1
```

I customized the container names using the Docker Compose instruction `container_name`

```conf 
webserver:                        #Service name
    container_name: webserver     #Container name
    image: webserver              #Image name
```


```bash
luicasad:~/inception$ docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED         STATUS                     PORTS                                       NAMES
fc35e7e5bcd0   webserver       "/usr/sbin/nginx -c …"   4 minutes ago   Up 4 minutes               0.0.0.0:443->443/tcp, :::443->443/tcp       webserver
ece86cb0a76a   contentserver   "/contentserver_setu…"   4 minutes ago   Up 4 minutes (healthy)     0.0.0.0:9000->9000/tcp, :::9000->9000/tcp   contentserver
baf676929a0e   adminerserver   "lighttpd -D -f /etc…"   4 minutes ago   Up 4 minutes (unhealthy)   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp     adminerserver
917e1d5ff1a4   dbserver        "/usr/local/sbin/doc…"   4 minutes ago   Up 4 minutes (healthy)     0.0.0.0:3306->3306/tcp, :::3306->3306/tcp   dbserver
```

I customized the network name using the Docker Compose instruction `name` together with the `networks` instruction.

``` conf

networks:
  inception_net:
    name: thenet
```


In this way, i converted `inception-contentserver-1.inception_inception_net` into `contentserver.thenet`

# Persistent volumes


```yaml
volumes:
  db_data:
    driver: local
    driver_opts:
      type: none
      device: /home/luicasad/data/db
      o: bind
  wp_data:
    driver: local
    driver_opts:
      type: none
      device: /home/luicasad/data/db
      o: bind
```


# Status of the project's containers.

It is possible to query the status of all containers in a project with `docker compose ps`.

### flag -f
One may specify the desired .yml configuration file by employing the -f flag.

```sh
luicasad:~$ docker compose -f inception/srcs/docker-compose.yml ps
NAME            IMAGE           COMMAND                  SERVICE         CREATED          STATUS                    PORTS
contentserver   contentserver   "/contentserver_setu…"   contentserver   21 minutes ago   Up 21 minutes (healthy)   0.0.0.0:9000->9000/tcp, :::9000->9000/tcp
dbserver        dbserver        "/usr/local/sbin/doc…"   dbserver        21 minutes ago   Up 21 minutes (healthy)   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp
webserver       webserver       "/usr/sbin/nginx -c …"   webserver       21 minutes ago   Up 20 minutes             0.0.0.0:443->443/tcp, :::443->443/tcp
```
### flag -p
Alternatively, the project name may be designated using the -p flag.

The initial line of the docker-compose.yml file serves to assign a name to the project. By naming the Docker Compose project, one enables the use of the -p flag within the command-line interface to facilitate targeted queries.

```yaml
name: inception
include:
  - ./requirements/dbserver/docker-compose-dbserver.yml
  - ./requirements/webserver/docker-compose-webserver.yml
  - ./requirements/contentserver/docker-compose-contentserver.yml
```

This approach permits the inspection of all containers associated with the project via a single command, irrespective of the current working directory.

``` sh
luicasad:~$ docker compose -p inception ps
NAME            IMAGE           COMMAND                  SERVICE         CREATED          STATUS                    PORTS
contentserver   contentserver   "/contentserver_setu…"   contentserver   18 minutes ago   Up 18 minutes (healthy)   0.0.0.0:9000->9000/tcp, :::9000->9000/tcp
dbserver        dbserver        "/usr/local/sbin/doc…"   dbserver        18 minutes ago   Up 18 minutes (healthy)   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp
webserver       webserver       "/usr/sbin/nginx -c …"   webserver       18 minutes ago   Up 18 minutes             0.0.0.0:443->443/tcp, :::443->443/tcp
```
### no flag 

It is also possible to achieve this by setting the environmental variable COMPOSE_PROJECT_NAME.



```sh
luicasad:~$ export COMPOSE_PROJECT_NAME=inception
luicasad:~$ docker compose  ps
NAME            IMAGE           COMMAND                  SERVICE         CREATED          STATUS                    PORTS
contentserver   contentserver   "/contentserver_setu…"   contentserver   22 minutes ago   Up 22 minutes (healthy)   0.0.0.0:9000->9000/tcp, :::9000->9000/tcp
dbserver        dbserver        "/usr/local/sbin/doc…"   dbserver        22 minutes ago   Up 22 minutes (healthy)   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp
webserver       webserver       "/usr/sbin/nginx -c …"   webserver       22 minutes ago   Up 22 minutes             0.0.0.0:443->443/tcp, :::443->443/tcp
```
