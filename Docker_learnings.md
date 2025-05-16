+ Each RUN command is a docker layer.
+ Gather in one RUN related commands to reduce the number of layer and consquently image size
+ First RUN less frequently changing commands


# Secrets
Using Docker secrets requires the initialitation of `docker swarm init`.


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
