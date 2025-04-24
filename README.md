# Inception: System Administration-related exercise.

This project aims to broaden my knowledge of system administration by using Docker.
I will virtualize several Docker images, creating them inside a virtual machine.
machine.

### General guidelines
• This project needs to be done on a **Virtual Machine**.
• All the files required for the configuration of your project must be placed in a srcs folder.
• A Makefile is also required and must be located at the root of your directory. It must set up your entire application (i.e., it has to build the Docker images using docker-compose.yml).
• This subject requires putting into practice concepts related to Docker usage.


+ This project sets up a small infrastructure composed of different services under specific rules. The whole project has to be done in a virtual machine.
+ You have to use **docker compose**.
+ Each Docker image must have the **same name as its corresponding service**.
+ Each service has to run in a **dedicated container**.
+ For performance matters, the containers must be built either from the penultimate stable version of **Alpine or from Debian**. The choice is yours.
+ You also have to **write your own Dockerfiles**, one per service. The Dockerfiles must be called in your docker-compose.yml by your Makefile.
+ It means you have to **build yourself the Docker images** of your project. It is then **forbidden to pull ready-made Docker images**, as well as using services such as DockerHub (Alpine/Debian being excluded from this rule).
+ Your containers have to restart in case of a crash.
+ Using network: host or --link or links: is **forbidden**.
+ The **network line must be present in your docker-compose.yml** file.
+ Your containers mustn’t be started with a command running an infinite loop. Thus, this also applies to any command used as an entry point, or used in entry point scripts. The following are a few prohibited hacky patches: tail -f, bash, sleep infinity, while true.
+ Configure your domain name so it points to your local IP address. This domain name must be login.42.fr. Again, you have to use your own login. For example, if your login is luis, luis.42.fr will redirect to the IP address pointing to luis’s website.
+ The latest tag is prohibited.
+ **No password must be present in your Dockerfiles**. It is mandatory to use environment variables. Also, it is strongly recommended to use a .env file to store environment variables. The .env file should be located at the root of the srcs directory.
+ Your NGINX container must be the **only entrypoint into your infrastructure via the port 443 only**, using the TLSv1.2 or TLSv1.3 protocol.

### Mandatory Part
You then have to set up:
• A Docker container that contains NGINX with TLSv1.2 or TLSv1.3 only.

• A Docker container that contains WordPress + php-fpm (it must be installed and configured) only without nginx.

• A Docker container that contains **MariaDB** only without nginx.

• A volume that contains your WordPress database.

• A second volume that contains your WordPress website files.

• A docker network that establishes the connection between your containers.

• In your WordPress database, there **must be two users**, one of them being the administrator. The administrator’s username **can’t contain admin/Admin or administrator/Administrator** (e.g., admin, administrator, Administrator, admin-123, and
so forth).

• Your volumes will be available in the /home/theuser/data folder of the host machine using Docker.


![image](https://github.com/user-attachments/assets/5b64cdf1-1511-43ca-9172-f005b40919fb)

### Bonus Part

Bonus list:
• Set up Redis cache for your WordPress website to properly manage the cache.

• Set up an FTP server container pointing to the volume of your WordPress website.

• Create a simple static website in the language of your choice except PHP (Yes, PHP is excluded!). For example, a showcase site or a site for presenting your resume.

• Set up Adminer (DBMS).

• Set up a service of your choice that you think is useful. During the defense, you will have to justify your choice.

A Dockerfile must be written for each extra service. Thus, each service will run inside its container and will have, if necessary, its dedicated volume.


### Alpine config
I have chosen Alpine Linux due to its small size. There is a version optimized for virtual systems. Alpine virtual with 66 MB. [alpine-virt-3.21.3-x86_64.iso](https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-virt-3.21.3-x86_64.iso)

It is a version designed to run in memory. You need to pay some attention to executing the script `alpine-setup` and ensure you define a [sys] filesystem and format default partitions to create a persistent configuration that exists next boot.

Include repositories from the community at setup. This allows us to install Docker and git later.
Create a user aside of root

apk add git


$ssh-keygen -t ed25519 -C "one mail here"
$ eval "$(ssh-agent -s)"
> Agent pid 59566
ssh-add ~/.ssh/id_ed25519

I configured a github repository to backup all configuration files.
apk add docker            // I installed version 27.3
apk add docker-compose    // I installed version 2.31



### docker compose
Uses a docker-compose.yml file to configure my microservices ecosystem. I need to use version 3.8 of configuration syntax accordingly with m version of docker and docker compose

Inception requires the configuration of 3 services
+ nginx
+ wordpress
+ mariadb
+ redis cache (bonus)
+ ftp server (bonus)
+ statis web (bonus)
+ adminer (bonus)

 ```yml
name: inception

services: 
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports: 
      - "8080:80"
 ```


#### URLs read
[Docke compatibility matrix](https://dockerpros.com/wiki/docker-compose-compatibility-matrix/)
[Install Maria db on alpine linux](https://www.librebyte.net/en/data-base/how-to-install-mariadb-on-alpine-linux/)
