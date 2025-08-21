# Inception: System Administration-related exercise (version 3.2)

This project aims to broaden your knowledge of system administration through the use
of Docker technology. You will virtualize several Docker images by creating them in your
new personal virtual machine.

### General guidelines
• This project must be completed on a **Virtual Machine**.
• All the files required for the configuration of your project must be placed in a srcs folder.
• A Makefile is also required and must be located at the root of your directory. It must set up your entire application (i.e., it has to build the Docker images using docker-compose.yml).
• This subject requires putting into practice concepts related to Docker usage.


+ This project involves setting up a small infrastructure composed of different services under specific rules.
+ You must use **docker compose**.
+ Each Docker image must have the **same name as its corresponding service**.
+ Each service must run in a **dedicated container**.
+ For performance reasons, the containers must be built either from the penultimate stable version of **Alpine or from Debian**. The choice is yours.
+ You also have to **write your own Dockerfiles**, one per service. The Dockerfiles must be called in your docker-compose.yml by your Makefile.
+ This means you must **build the Docker images** for your project yourself. It is then **forbidden to pull ready-made Docker images**, as well as using services such as DockerHub (Alpine/Debian being excluded from this rule).
+ Your containers must restart automatically in case of a crash.
+ Using network: host or --link or links: is **forbidden**.
+ The **network line must be present in your docker-compose.yml** file.
+ Your containers mustn’t be started with a command running an infinite loop. Thus, this also applies to any command used as an entry point or used in entry point scripts. The following are a few prohibited hacky patches: tail -f, bash, sleep infinity, while true.
+ Configure your domain name to point to your local IP address. This domain name must be login.42.fr. Again, you have to use your login. For example, if your login is luis, luis.42.fr will redirect to the IP address pointing to luis’s website.
+ The latest tag is prohibited.
+ **No password must be present in your Dockerfiles**. It is mandatory to use environment variables. Also, it is strongly recommended to use a .env file to store environment variables. The .env file should be located at the root of the srcs directory.
+ Your NGINX container must be the **only entry point into your infrastructure via port 443 only**, using the TLSv1.2 or TLSv1.3 protocol.

### Mandatory Part
You then have to set up:
• A Docker container that contains NGINX with TLSv1.2 or TLSv1.3 only.

• A Docker container that contains WordPress + php-fpm (it must be installed and configured), only without nginx.

• A Docker container that contains only **MariaDB**,without nginx.

• A volume that contains your WordPress database.

• A second volume that contains your WordPress website files.

• A Docker network that establishes the connection between your containers.

• In your WordPress database, there **must be two users**, one of them being the administrator. The administrator’s username **can’t contain admin/Admin or administrator/Administrator** (e.g., admin, administrator, Administrator, admin-123, and
so forth).

• Your volumes will be available in the /home/theuser/data folder of the host machine using Docker.


![image](https://github.com/user-attachments/assets/5b64cdf1-1511-43ca-9172-f005b40919fb)

Expected directory structure
![image](https://github.com/user-attachments/assets/7f97bd32-ac7b-4727-b5e7-0bc3e7009179)

"For obvious security reasons, all credentials—such as API keys, passwords, and similar sensitive data—must be stored locally using appropriate methods or files, and excluded from Git tracking. Exposing credentials publicly will almost certainly fail the project."

You can store your variables (as a domain name) in an environment variable file, like .env

### Bonus Part

Bonus list:
• Set up Redis cache for your WordPress website to properly manage the cache.

• Set up an FTP server container pointing to the volume of your WordPress website.

• Create a simple static website in the language of your choice, except PHP (Yes, PHP is excluded!). For example, a showcase site or a site for presenting your resume.

• Set up Adminer (DBMS).

• Set up a service of your choice that you think is useful. During the defense, you will have to justify your choice.

A Dockerfile must be written for each extra service. Thus, each service will run inside its container and will have, if necessary, its dedicated volume.

### Virtual Machine
I use VirtualBox.

Oracle's VirtualBox is a free and open-source virtualization software that allows me to run multiple Alpine Linux instances as guest operating systems on my Ubuntu Linux host."

Two considerations:
+ Network configuration: Bridge. I want the virtual machine to get an IP in the same network as my host Machine
+ **check this** Shared folder: I prefer to edit all configuration files outside the virtual machine. I work on a folder in the host machine that is automatically mounted in the virtual machine at boot time (edited /etc/fstab)
+ Shared folder secrets: I will define text files with passwords outside



### Alpine config
I have chosen Alpine Linux due to its small size. We have 35 GB in two folders in 42. One folder in our login with 5 GB. 30 GB in a shared disk where, from time to time, the administrator frees the space of big users....

Also, because I know myself and I know that I will made many mistakes requiring rebooting the virtual machine. I did not want to get older watching screens rebooting. You know what I mean....

There is a version optimized for virtual systems. Alpine virtual with 66 MB. [alpine-virt-3.21.3-x86_64.iso](https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-virt-3.21.3-x86_64.iso)

It is a version designed to run in memory. You need to pay some attention to executing the script `alpine-setup` and ensure you define a [sys] filesystem and format default partitions to create a persistent configuration that exists next boot.

Include repositories from the community at setup. This allows us to install Docker and git later.
Create a user aside of root
`
apk add git


$ssh-keygen -t ed25519 -C "one mail here"
$ eval "$(ssh-agent -s)"
> Agent pid 59566
ssh-add ~/.ssh/id_ed25519

I configured a GitHub repository to back up all configuration files.

apk add docker            // I installed version 27.3
apk add docker-compose    // I installed version 2.31
docker swarn init 

Subject requests me to write a Makefile, so I need make

apk add make

##### ssh-agent starts at boot time
In the previous section, I manually started the SSH agent to add the private key for connecting with Git Hub.
I need the SSH agent to be active for the "luicasad" user. I configure the inception project with this user. I synchronize the inception repository from Git Hub.
I created a ~/.profile file to execute at login time

```bash
echo "Logged in as: $(whoami)"
echo "Hostname    : $(hostname)"
echo "kernel      : $(uname -r)"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/alpine_inception

```


### docker compose
Uses a docker-compose.yml file to configure my microservices ecosystem. I need to use version 3.8 of the configuration syntax accordingly to my version of Docker and Docker Compose

Inception requires the configuration of 3 services
+ nginx
+ wordpress
+ mariadb
+ redis cache (bonus)
+ ftp server (bonus)
+ static web (bonus)
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

##### real-time file update inside your container when you edit it on the host.

There is a `watch` instruction in compose language to update a file inside a container

```yml
    develop:
      watch:
        - action: sync
          path: .
          target: /code
```

####

This project relies on two scripts that run during the virtual machine's boot time.

Behind the scenes, once an IP number is available, the /etc/hosts file is configured, SSL certificates are generated in /home/luicasad/data/certs, and two folders are created in /home/luicasad/data to host the volumes that ensure data persistence for the database (db) and WordPress (wp).

Passwords stored on the host machine are transferred to the virtual machine via VirtualBox’s shared folder functionality. These are mounted at /home/luicasad/secrets.

Docker Swarm converts them into secrets via the scripts/secrets_setup.start script.

The docker-compose.yml file defines the project name, includes the Docker Compose files for each service, and sets up a network with 16 possible IPs, assigning a fixed IP to each container. It also defines the volumes for persistence and the secrets.

Each service has its own Dockerfile and configuration script.

It’s necessary to analyze which users are created in each container during software installation and what type they are.

When installing MariaDB, a mysql user is created with a low UID-GID and no login shell. In my case, that UID coincides with the UID of klogd on the virtual machine, which has led to permission conflicts.

I’ve decided that MariaDB should not run as root.

To prepare for potentially needing to recreate the virtual machine, there’s a script for that: scripts/inception_alpine_setup.sh.


### Learnings.

I learnt a lot in the different subjects this project treats.

[Alpine Linux](learnings/Alpine_linux_learnings.md)
[Docker](learnings/Docker_learnings.md)
[Git](learnings/Git_learnings.md)
[MariaDB](learnings/Mariadb_learnings.md)
[PHP_FPM](learnings/PHP_FPM_learnings.md)
[VirtualBox](learnings/VirtualBox_learnings.md)
[Wordpress](learnings/Wordpress_learnings.md)
[Nginx](learnings/nginx_learnings.md)



#### URLs read
+ [Alpine Linux setup](https://wiki.alpinelinux.org/wiki/Installation#Installation_Handbook)

+ [Docker reference](https://docs.docker.com/reference/)

+ [Docker compatibility matrix](https://dockerpros.com/wiki/docker-compose-compatibility-matrix/)

+ [Install Maria db on alpine linux](https://www.librebyte.net/en/data-base/how-to-install-mariadb-on-alpine-linux/)

+ [Services in Alpine-linux-containers](https://medium.com/@mfranzon/how-to-create-and-manage-a-service-in-an-alpine-linux-container-93a97d5dad80)
+ [Docekr maria db  video](https://event.on24.com/eventRegistration/console/apollox/mainEvent?&eventid=1843295&sessionid=1&username=&partnerref=&format=fhvideo1&mobile=&flashsupportedmobiledevice=&helpcenter=&key=B28CF0CD422B7C4BDA4B2DD12C498B6B&newConsole=true&nxChe=true&newTabCon=true&consoleEarEventConsole=true&consoleEarCloudApi=false&text_language_id=en&playerwidth=748&playerheight=526&eventuserid=752113287&contenttype=A&mediametricsessionid=645792338&mediametricid=2595708&usercd=752113287&mode=launch)

+ [MariaDb Dockerfile Template](https://github.com/mariadb-corporation/mariadb-server-docker/blob/master/Dockerfile.template)
+ [Docker Labels Schema](http://label-schema.org/rc1/#:~:text=of%20the%20code.-,schema%2Dversion,docker.cmd)
+ [The twelve-factor app](https://12factor.net/)
+ [PHP manual](https://www.php.net/manual/en/index.php)
+ [Nginx Server block selection](https://www.digitalocean.com/community/tutorials/understanding-nginx-server-and-location-block-selection-algorithms)



