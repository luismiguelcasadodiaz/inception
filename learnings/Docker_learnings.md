+ Each RUN command is a docker layer.
+ Gather in one RUN related commands to reduce the number of layer and consquently image size
+ First RUN less frequently changing commands


# Secrets
Using Docker secrets requires the initialitation of `docker swarm init`.

Secrets are not visible inside a Dockerfile. I discover this with dbserver healthcheck.

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
  - all images without at least one container associated to them
  - all build cache

we can use ...

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

# logs sizes
 My aim is to keep small the virtual machine harddisk size. This is why i limit log file size and number of log files to keep

```yaml

    logging:
      driver: "json-file" # Use json-file for easier access if you need to debug raw logs
      options:
        max-size: "25600" # Keep each log file up to 25600 Bytes or "25k"
        max-file: "3"   # Keep the 5 most recent log files      
```

To know where log file is saved we can use this command

```bash
docker inspect --format='{{.LogPath}}' inception-dbserver-1
/var/lib/docker/containers/d80c94c4acd52cd1996443de34c589cefab23340fa148ac44da67cc9a067dfe1/d80c94c4acd52cd1996443de34c589cefab23340fa148ac44da67cc9a067dfe1-json.log

```

# healthcheck

To be sure  dbserver is up and runnig before other containers start, a healthcheck is available in Dockerfile.

But Dockerfile has not access to secrets. Dockerfile can read .ENV defined enviromental variables.

I do not want to duplicate where password are kept, so i decide the creation os a healthcheck script for this pourpouse

```Dockerfile
#HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD mariadb-admin ping -u mysql --password="${DBSERVER_MSQL_PASSWORD}"-h localhost || exit 1
#  Dockerfile does not acces secrets, only .env defined variables. These is the reason to create a healthycheck script.
HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD /usr/local/sbin/healthcheck.sh || exit 1

```

The docker-compose files of dependant containers must have the instruction `depends_on`

```yaml
    depends_on:
      dbserver:
        condition: service_healthy  # Ensures database server is actually ready
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

It is possible the customization of container names using the docker compose instruction `container_name`

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

It is also possible the customization of network  names using the docker compose instruction `name` together with `networks` instuctions.

``` conf

networks:
  inception_net:
    name: thenet
```


In this way i converted `inception-contentserver-1.inception_inception_net` into `contentserver.thenet`

