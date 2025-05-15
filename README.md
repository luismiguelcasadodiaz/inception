# Inception: System Administration-related exercise (version 3.2)

This project aims to broaden your knowledge of system administration through the use
of Docker technology. You will virtualize several Docker images by creating them in your
new personal virtual machine.

### General guidelines
• This project must be completed on a **Virtual Machine**.
• All the files required for the configuration of your project must be placed in a srcs folder.
• A Makefile is also required and must be located at the root of your directory. It must set up your entire application (i.e., it has to build the Docker images using docker-compose.yml).
• This subject requires putting into practice concepts related to Docker usage.


+ This project involves setting up a small infrastructure composed of different services un-
der specific rules.
+ You must use **docker compose**.
+ Each Docker image must have the **same name as its corresponding service**.
+ Each service has to run in a **dedicated container**.
+ For performance reasons, the containers must be built either from the penultimate stable version of **Alpine or from Debian**. The choice is yours.
+ You also have to **write your own Dockerfiles**, one per service. The Dockerfiles must be called in your docker-compose.yml by your Makefile.
+ This means you must **build the Docker images** for your project yourself. It is then **forbidden to pull ready-made Docker images**, as well as using services such as DockerHub (Alpine/Debian being excluded from this rule).
+ Your containers must restart automatically in case of a crash.
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

• A Docker container that contains only **MariaDB**,without nginx.

• A volume that contains your WordPress database.

• A second volume that contains your WordPress website files.

• A docker network that establishes the connection between your containers.

• In your WordPress database, there **must be two users**, one of them being the administrator. The administrator’s username **can’t contain admin/Admin or administrator/Administrator** (e.g., admin, administrator, Administrator, admin-123, and
so forth).

• Your volumes will be available in the /home/theuser/data folder of the host machine using Docker.


![image](https://github.com/user-attachments/assets/5b64cdf1-1511-43ca-9172-f005b40919fb)

Expected directory structure
![image](https://github.com/user-attachments/assets/7f97bd32-ac7b-4727-b5e7-0bc3e7009179)

For obvious security reasons, any credentials, API keys, passwords,etc., must be saved locally in various ways / files and ignored by git. Publicly stored credentials will lead you directly to a failure of the project.

You can store your variables (as a domain name) in an environment variable file like .env

### Bonus Part

Bonus list:
• Set up Redis cache for your WordPress website to properly manage the cache.

• Set up an FTP server container pointing to the volume of your WordPress website.

• Create a simple static website in the language of your choice except PHP (Yes, PHP is excluded!). For example, a showcase site or a site for presenting your resume.

• Set up Adminer (DBMS).

• Set up a service of your choice that you think is useful. During the defense, you will have to justify your choice.

A Dockerfile must be written for each extra service. Thus, each service will run inside its container and will have, if necessary, its dedicated volume.

### Virtual Machine
I use Virtual box.

VirtualBox from Oracle is a free and open-source virtualization software package that allows me to run multiple Alpine Linux, as guest operating systems, on my linux Ubuntu host operating system.

Two considerations:
+ Network configuration:Bridge. I want the virtual machine gets a IP in the same net that my host Machine
+ Shared folder: I prefer edit all configuration files outside the virtual machine. I work on a folder in the host machine that it is automatically mounted in the virtual machine at boot time (edited /etc/fstab)

During the project the original 2GB disk was not enough. Early in the project docker compose reported `no space left on device`.

I duplicated hard disk size wiht this commands

```bash
VBoxManage modifymedium disk "/sgoinfre/students/luicasad/maria/maria/inception Clone.vdi" --resize 4096
VBoxManage showhdinfo "/sgoinfre/students/luicasad/maria/maria/inception Clone.vdi"
```

That requires a edition of the virtual machine partition table. With `fdisk /dev/sda` deleted 3rd partition `-d` without erase data.
That requires a file system extension. `resize2fs /dev/sda3` made it possible.

### Alpine config
I have chosen Alpine Linux due to its small size. There is a version optimized for virtual systems. Alpine virtual with 66 MB. [alpine-virt-3.21.3-x86_64.iso](https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-virt-3.21.3-x86_64.iso)

It is a version designed to run in memory. You need to pay some attention to executing the script `alpine-setup` and ensure you define a [sys] filesystem and format default partitions to create a persistent configuration that exists next boot.

Include repositories from the community at setup. This allows us to install Docker and git later.
Create a user aside of root
`
apk add git


$ssh-keygen -t ed25519 -C "one mail here"
$ eval "$(ssh-agent -s)"
> Agent pid 59566
ssh-add ~/.ssh/id_ed25519

I configured a github repository to backup all configuration files.
apk add docker            // I installed version 27.3
apk add docker-compose    // I installed version 2.31

Subject request me to write a Makefile, so i need make
apk add make

##### ssh-agent start at boot time
In previous section, i started ssh-agent manually to add the private key to connect wiht Git Hub.
I need ssh-agent to be active for "luicasad" user. I configure inception project wiht this user. I syncronize inception repository from Git Hub.
I created a ~/.profile file to execute at login time

```ash
echo "Logged in as: $(whoami)"
echo "Hostname    : $(hostname)"
echo "kernel      : $(uname -r)"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/alpine_inception

```



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

##### real time file update inside your container when you edit it in host.

There is a `watch` instruction in compose language to update a file inside a container

```yml
    develop:
      watch:
        - action: sync
          path: .
          target: /code
```

#### URLs read
+ [Alpine Linux setup](https://wiki.alpinelinux.org/wiki/Installation#Installation_Handbook)

+ [Docker reference](https://docs.docker.com/reference/)

+ [Docker compatibility matrix](https://dockerpros.com/wiki/docker-compose-compatibility-matrix/)

+ [Install Maria db on alpine linux](https://www.librebyte.net/en/data-base/how-to-install-mariadb-on-alpine-linux/)

+ [Services in Alpine-linux-containers](https://medium.com/@mfranzon/how-to-create-and-manage-a-service-in-an-alpine-linux-container-93a97d5dad80)
+ [Docekr maria db  video](https://event.on24.com/eventRegistration/console/apollox/mainEvent?&eventid=1843295&sessionid=1&username=&partnerref=&format=fhvideo1&mobile=&flashsupportedmobiledevice=&helpcenter=&key=B28CF0CD422B7C4BDA4B2DD12C498B6B&newConsole=true&nxChe=true&newTabCon=true&consoleEarEventConsole=true&consoleEarCloudApi=false&text_language_id=en&playerwidth=748&playerheight=526&eventuserid=752113287&contenttype=A&mediametricsessionid=645792338&mediametricid=2595708&usercd=752113287&mode=launch)

+ [MariaDb Dockerfile Template](https://github.com/mariadb-corporation/mariadb-server-docker/blob/master/Dockerfile.template)
+ [Docker Labels Schema](http://label-schema.org/rc1/#:~:text=of%20the%20code.-,schema%2Dversion,docker.cmd)