# Version

I use an Alpine Linux version with a slimmed-down kernel. Optimized for virtual systems.[Named virtual ](https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-virt-3.21.3-x86_64.iso)

It is a volatile version designed to exist only in RAM. Running setup, you MUST make the file system persistent

# Login
User root has no password. FIX this at setup.

# setup-alpine
This is the script to configure Alpine Linux
+ select keyboard map: us us ---> to fit with 42 Mac keyboards
+ select hostname: localhost [default]
+ Interface:
    + to initialize: eth0 [default]
    + Ip address for eth0: dhcp [default]
    + any manual network configuration: n [default]

+ Root Password:
+ TimeZone: Europe Madrid
+ Proxy: none [default]
+ Network Time Protocol: chrony [default]
+ APK Mirror
    + Enable community repositories (c). Required to download Docker, Git, etc...
    + Find and use the fastest mirror (f) --> mirror.raiolanetworks.net Lugo, Spain  NUMBER 84
+ user: no  [default] --> I will create it later with the UID/GID luicasad has in hostmachine
+ ssh
    + server: openssh [default]
    + root login prohibit-password [default]
    + root key: nono [default]
+ Disk & Install
    + disk to use: sda
    + how to use it: sys  --> I want SDA to become a system disk.
    + Erase sda disk and continue: y


# /etc/fstab

Configure automounting the shared folder between the host machine and the virtual machine. Add this line

```bash
inception_host	/home/luicasad/inception_host	vboxsf	defaults	0	0
or
inception  /home/luicasad vboxsf user,uid=101177,gid=4223,rw,auto 0 0

```

🚫
You're absolutely right — and this is a known limitation of vboxsf (VirtualBox Shared Folders):

Even with uid= and gid= options in /etc/fstab, vboxsf mounts are always owned by root:vboxsf, and Alpine (or other Linux guests) can't force a change in that ownership.

This is not a bug in Alpine, but a design limitation of the VirtualBox shared folder driver.

# add new user

I want my user luicasad in the virtual machine to have the same UID/gid as the ones I have in my host machine. This will help me later to push changes from the virtual machine to my repositories

```bash
id luicasad
uid=101177(luicasad) gid=4223(2023_barcelona) groups=204(_developer),4223(2023_barcelona)
```


```sh
addgroup -g 4223 2023_barcelona
adduser -u 101177 -G 2023_barcelona -D luicasad
adduser luicasad docker
```

# install required packages

apk add git
apk add make
apk add jq
apk add docker
apk add docker-compose


# docker wakes up at boot time.
```sh
rc-update add docker boot
rd-service docker start
```

# init swarm service for secrets

```sh
docker swarm init
```

# allow my user to run Docker
```sh
adduser luicasad docker
```

# keys

Copy your id_rsa key from your 42 school home directory to work with the delivery repository

# /bin/sh



On Alpine Linux, /bin/sh is usually a POSIX shell (ash), which does not support ${!var}, an `indirect parameter expansion`. 
The indirect parameter expansion is a bash feature.

My DB container entrypoint script gave me an error `line 77: syntax error: bad substitution`


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

I solved it like this

```sh
    local password=$(read_secret "$file_var")
```

# configure /etc/hosts

Inception subject says: 

+ You must configure your **domain name to point to your local IP address**. This domain name must be luicasad.42.fr.

Despite Alpine Linux having a `setup-hostname` command, the result does not affect `etc/hosts` .

```bash
/ # setup-hostname 
Enter system hostname (fully qualified form, e.g. 'foo.example.org') [luicasad.42.fr] 
/ # cat /etc/hosts
127.0.0.1	luicasad.42barcelona.com luicasad localhost.localdomain localhost
::1		localhost localhost.localdomain
/ # 
```

Additionally, the network interface I work with in the Oracle VirtualBox is a bridge, so my VM gets its IP dynamically from 42's DHCP.

I ask at booting time to update `/etc/hosts` with the current IP running `/etc/local.d/update_hosts.start`

# SQL syntax and /bin/sh

Blending environment variables with SQL sentences created at runtime was not straightforward.

## My **first approach** inside the dbserver's  `docker-entrypoint.sh` was:

```sh
mariadb -u root -e "CREATE DATABASE IF NOT EXISTS '$DATABASE_NAME';" -S /run/mysqld/mysqld.sock
```

That expanded and behaved like this
```sh 
mariadb -u root -e 'CREATE DATABASE IF NOT EXISTS '"'"'WORDPRESS'"'"';' -S /run/mysqld/mysqld.sock
--------------
CREATE DATABASE IF NOT EXISTS 'WORDPRESS'
--------------
ERROR 1064 (42000) at line 1: You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near ''WORDPRESS'' at line 1
```
Using single quotes ('WORDPRESS') makes MariaDB interpret "WORDPRESS" as a string literal, not a database name. I cannot create a database with a string literal as its name.

In SQL:

+ Single quotes (') are used to delimit string literals (e.g., 'hello world'). You use these for data values.

+ Backticks (`) are used to delimit identifiers (like database names, table names, column names) when those identifiers contain special characters, spaces, or are reserved keywords.

## My **second approach** was


```sh
mariadb -u root -e "CREATE DATABASE IF NOT EXISTS `$DATABASE_NAME`;" -S /run/mysqld/mysqld.sock
```

and the error inside the dbserver's  `docker-entrypoint.sh` changed to the error message:

```sh
/usr/local/sbin/docker-entrypoint.sh: line 60: WORDPRESS: not found
+ mariadb -u root -e 'CREATE DATABASE IF NOT EXISTS ;' -S /run/mysqld/mysqld.sock
```


The reason behind this change was the fact that in shell scripting, when you wrap a command in backticks `command`, the shell:
+ Executes the command inside the backticks.
+ Captures the output of that command.
+ Substitutes the backtick expression with that output.

In such a way that 
```sh
echo "Today is: `date`"
```
becomes 
```sh
Today is: Fri Jun 28 12:34:56 UTC 2024
```

There is no `wordpress` command in `/bin/sh`'s path


The Solution: Escaping the Backticks for Literal Use. You need the backticks to be passed literally to the mariadb command for SQL, not interpreted by the shell for command substitution. To do this, you must escape the backticks with a backslash when they are inside double quotes.

```sh
mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`$DATABASE_NAME\`;" -S /run/mysqld/mysqld.sock
```


### graphical interface

#### 1.- Which one? A small one.

| Environment                  | HD requirements  (aprox.) | Stand-by RAM  (aprox.) |
| ---------------------------- | ------------------------- | ---------------------- |
| **XFCE**                     | 300–450 MB                | 200–300 MB             |
| **LXDE**                     | 250–350 MB                | 150–200 MB             |
| **MATE**                     | 500–700 MB                | 300–400 MB             |
| **Openbox** (WM only)        | 100–150 MB                | 60–100 MB              |
| **i3wm** (WM only)           | 100–150 MB                | 60–100 MB              |
| **Fluxbox**                  | 100–150 MB                | 50–90 MB               |
| **JWM**                      | 70–120 MB                 | 50–80 MB               |
| **GNOME** *(no recommended)* | 1–2 GB                    | 700–1000+ MB           |
| **KDE Plasma** *(heavy)*     | 1.5–2.5 GB                | 600–1000+ MB           |

In the table, the indication "(WM only)" means "Window Manager only", in contrast to a "full desktop environment" (DE).

Both Openbox and i3wm are minimalistic window managers (WMs), and while they consume similar resources, they differ significantly in design philosophy, workflow, and user interaction. Here's a clear comparison:

| **Aspect**                 | **Openbox**                                     | **i3wm**                                              |
| -------------------------- | ----------------------------------------------- | ----------------------------------------------------- |
| **Type**                   | Stacking window manager                         | Tiling window manager                                 |
| **User interaction model** | Mouse-driven with optional keyboard usage       | Keyboard-centric (mouse optional)                     |
| **Window organization**    | Windows float freely and can overlap            | Windows auto-tile (no overlap)                        |
| **Configuration**          | XML files (`~/.config/openbox/rc.xml`)          | Plain-text file (`~/.config/i3/config`)               |
| **Learning curve**         | Low – intuitive for users of traditional WMs    | Medium – requires learning tiling logic & keybindings |
| **Out-of-the-box UX**      | Lightweight but basic; needs panel, launcher    | Integrated bar, launcher, and keybindings             |
| **Customization**          | Very high (theme-based, menus, etc.)            | High (layouts, rules, scripting)                      |
| **Use case fit**           | Lightweight alternative to traditional desktops | Productivity-focused workflows (devs, analysts)       |
| **Dependencies**           | Fewer (if avoiding full DE)                     | Slightly more due to bar, dmenu, etc.                 |

In the context of Alpine Linux inside VirtualBox:
+ Performance: Both are extremely lightweight and suitable for Alpine's minimalist philosophy.
+ Mouse support: If your VirtualBox setup passes mouse input correctly and you prefer GUI interaction, Openbox is easier to handle.
+ Keyboard-centric workflows: If you're comfortable working mostly via keyboard (e.g., for coding, tiling multiple terminals), i3wm is more efficient.
+ Ease of setup: Openbox might be easier for first-time users due to its simpler window behavior and GUI menus.


I chose **Openbox** due to I want something that "just works" with basic GUI behavior and sets up a lightweight graphical environment (e.g., to run a browser or basic GUI tools).

#### 2. Installing the Minimum Required Packages

I installed only the essential packages to run X and Openbox:

```sh
apk add openbox xinit xorg-server xf86-video-vesa xf86-input-evdev ttf-dejavu firefox xterm
```

xinit contains:
+ startx: script to launch X from the console.
+ xinit: backend that launches the X server and client defined in .xinitrc.

#### 3.- Configuring X to Recognize Input Devices in VirtualBox

VirtualBox passes mouse input through multiple virtual devices (movement, clicks, scroll). Alpine did not detect them correctly by default.

We created a manual /etc/X11/xorg.conf to assign:

+ event0 → keyboard
+ event3 → mouse movement
+ event4 → mouse buttons and scroll

##### /etc/X11/xorg.conf

```conf
Section "ServerLayout"                                                          
    Identifier     "Default Layout"                                             
    Screen         "Default Screen"                                             
    InputDevice    "Keyboard0" "CoreKeyboard"                                   
    InputDevice    "Mouse0" "CorePointer"                                       
    InputDevice    "Mouse1" "SendCoreEvents"                                    
EndSection                                                                      
                                                                                
Section "InputDevice"                                                           
    Identifier     "Keyboard0"                                                  
    Driver         "evdev"                                                      
    Option         "Device" "/dev/input/event0"                                 
EndSection                                                                      
                                                                                
Section "InputDevice"                                                           
    Identifier     "Mouse0"                                                     
    Driver         "evdev"                                                      
    Option         "Device" "/dev/input/event3"                                 
EndSection                                                                      
                                                                                
Section "InputDevice"                                                           
    Identifier     "Mouse1"                                                     
    Driver         "evdev"                                                      
    Option         "Device" "/dev/input/event4"                                 
EndSection                                                                      
                                                                                
Section "Monitor"                                                               
    Identifier     "Monitor0"                                                   
EndSection                                                                      
                                                                                
Section "Device"                                                                
    Identifier     "Card0"                                                      
    Driver         "modesetting"                                                
EndSection                                                                      
                                                                                
Section "Screen"                                                                
    Identifier     "Default Screen"                                             
    Device         "Card0"                                                      
    Monitor        "Monitor0"                                                   
EndSection 
```
##### Uncover which device gets which kind of event

+ 1.- list available input devices

```sh
/home/luicasad # ls -al /dev/input/
total 0
drwxr-xr-x    2 root     root           200 Jul 13 11:32 .
drwxr-xr-x   13 root     root          2800 Jul 13 11:33 ..
crw-rw----    1 root     input      13,  64 Jul 13 11:32 event0
crw-rw----    1 root     input      13,  65 Jul 13 11:32 event1
crw-rw----    1 root     input      13,  66 Jul 13 11:32 event2
crw-rw----    1 root     input      13,  67 Jul 13 11:32 event3
crw-rw----    1 root     input      13,  68 Jul 13 11:32 event4
crw-rw----    1 root     input      13,  63 Jul 13 11:32 mice
crw-rw----    1 root     input      13,  32 Jul 13 11:32 mouse0
crw-rw----    1 root     input      13,  33 Jul 13 11:32 mouse1
```

+ 2.- listen one by one

```sh
cat /dev/input/event3
```

While you move the mouse in the virtual machine or type on the keyboard.
The one that shows data coming is the one to map inside the `xorg.conf` file


#### 4.-User Permissions for Running a Graphical Environment in Alpine Linux

To allow an unprivileged user (`luicasad`) to successfully start a graphical session with Openbox and capture keyboard and mouse input in Alpine Linux (inside VirtualBox), the user must belong to the following groups:

| Group   | Purpose                                             |
|---------|-----------------------------------------------------|
| `video` | Grants access to graphics acceleration devices (`/dev/dri/*`) |
| `input` | Grants access to keyboard and mouse events (`/dev/input/*`)  |



```sh
adduser luicasad video
adduser luicasad input
```

#### 5.- Launch openbox at login time.
To automatically start up in a graphical environment that shows a login screen (greeter), I need a **display manager**, which is the component responsible for:

+ Automatically starting the X server at startup
+ Displaying a graphical login screen (GUI)
+ Launching the desktop or window manager (in your case, OpenBox) after logging in

We intentionally avoided using a **display manager**, choosing only a **window manager** (OpenBox). There is no "greeter screen".
Instead, we configured the system to start X and Openbox automatically after the user logs in manually from TTY1.

+ Step 1: Created ~/.profile with:

```sh
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec startx
fi
```

+ Step 2: Created ~/.xinitrc with:

```sh
exec openbox-session
```


#### 6. Customizing the Openbox Menu for luicasad user
I cluttered the default Openbox menu  with unnecessary entries. 
I replaced it with a minimal menu containing only:

+ Browser ==> Firefox
+ Terminal ==> xterm
+ Exit

In ~/.config/openbox/menu.xml:

```xml
<?xml version="1.0" encoding="UTF-8"?>            
                                                  
<openbox_menu xmlns="http://openbox.org/3.4/menu">
                                            
                                            
<menu id="root-menu" label="Openbox 3">     
  <separator label="Inception" />      
  <item label="Browser">               
    <action name="Execute">            
      <command>firefox</command>       
      <startupnotify>                  
        <enabled>yes</enabled>         
      </startupnotify>                 
    </action>                          
  </item>                              
  <item label="Terminal">              
    <action name="Execute">            
      <command>xterm</command>         
      <startupnotify>                  
        <enabled>yes</enabled>         
      </startupnotify>                 
    </action>                                        
  </item>                              
  <!--
    <item label="Reconfigure Openbox">   
    <action name="Reconfigure" />                    
  </item>                              
  -->
  <item label="Log Out">               
    <action name="Exit">                 
      <prompt>yes</prompt>             
    </action>                          
  </item>                              
</menu>                                
                                            
</openbox_menu>   

```




```sh
rc-update add udev
rc-update add dbus

rc-service udev start
rc-service dbus start
```

#### 7. Cliboard

+ Step 1: In the VirtualBox settings for the virtual machine, in General/Advanced, Ensure Shared Clipboard is set to Bidirectional

+ step 2: install additions that support X11.

```sh
apk add virtualbox-guest-additions-x11
```

+ Step 2: modify  ~/.xinitrc with:

Launch before opening the openbox-session, the clipboard in the background.

```sh
VBoxClient --clipboard &
exec openbox-session
```

# Services boot order.

After rebooting my virtual machine, I faced the problem that not all my services restarted.

```sh
luicasad:~$ docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED          STATUS                    PORTS                                       NAMES
68d816a23e80   webserver       "/usr/sbin/nginx -c …"   35 minutes ago   Up 16 seconds             0.0.0.0:443->443/tcp, :::443->443/tcp       webserver
```

I discovered that the secrets were not available when the containers were starting, so they failed silently. The runlevel `boot` executes before the runlevel `default`.
`Docker` was at `boot` Runlevel, starting before `virtualbox-guest-additions` mounted secrets.


```sh
luicasad:~$ rc-status -a
Runlevel: sysinit
 devfs                                [  started  ]
 dmesg                                [  started  ]
 mdev                                 [  started  ]
 hwdrivers                            [  started  ]
Runlevel: boot
 modules                              [  started  ]
 hwclock                              [  started  ]
 swap                                 [  started  ]
 seedrng                              [  started  ]
 sysctl                               [  started  ]
 bootmisc                             [  started  ]
 loadkmap                             [  started  ]
 hostname                             [  started  ]
 networking                           [  started  ]
 docker                   [  started 00:07:42 (0) ]
 syslog                               [  started  ]
Runlevel: shutdown
 savecache                            [  stopped  ]
 killprocs                            [  stopped  ]
 mount-ro                             [  stopped  ]
Runlevel: default
 acpid                                [  started  ]
 crond                                [  started  ]
 chronyd                              [  started  ]
 sshd                                 [  started  ]
 virtualbox-guest-additions           [  started  ]
 local                                [  started  ]
Runlevel: nonetwork
Dynamic Runlevel: hotplugged
Dynamic Runlevel: needed/wanted
 sysfs                                [  started  ]
 fsck                                 [  started  ]
 root                                 [  started  ]
 localmount                           [  started  ]
 cgroups                              [  started  ]
Dynamic Runlevel: manual
```

I moved `virtualbox-guest-additions` from `default` Runlevel to `boot` Runlevel

```sh
rc-update add virtualbox-guest-additions boot
rc-update del virtualbox-guest-additions default
```

```sh
/home/luicasad # rc-status -a
Runlevel: sysinit
 devfs                                [  started  ]
 dmesg                                [  started  ]
 mdev                                 [  started  ]
 hwdrivers                            [  started  ]
Runlevel: boot
 modules                              [  started  ]
 hwclock                              [  started  ]
 swap                                 [  started  ]
 seedrng                              [  started  ]
 sysctl                               [  started  ]
 bootmisc                             [  started  ]
 loadkmap                             [  started  ]
 hostname                             [  started  ]
 networking                           [  started  ]
 virtualbox-guest-additions           [  started  ]
 docker                   [  started 00:00:50 (0) ]
 syslog                               [  started  ]
Runlevel: shutdown
 savecache                            [  stopped  ]
 killprocs                            [  stopped  ]
 mount-ro                             [  stopped  ]
Runlevel: default
 acpid                                [  started  ]
 crond                                [  started  ]
 chronyd                              [  started  ]
 sshd                                 [  started  ]
 local                                [  started  ]
Runlevel: nonetwork
Dynamic Runlevel: hotplugged
Dynamic Runlevel: needed/wanted
 sysfs                                [  started  ]
 fsck                                 [  started  ]
 root                                 [  started  ]
 localmount                           [  started  ]
 cgroups                              [  started  ]
Dynamic Runlevel: manual
```

But it was not enough. I edited `/etc/init.d/docker` to create a dependency from `virtualbox-guest-additions`

```sh
depend() {
        need sysfs cgroups net
        after firewall
        use virtualbox-guest-additions  <<=======
}
```

In that way, after rebooting, the `restart: always` instruction  restarted the container:

```sh
luicasad:~$ docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED          STATUS                    PORTS                                       NAMES
68d816a23e80   webserver       "/usr/sbin/nginx -c …"   35 minutes ago   Up 16 seconds             0.0.0.0:443->443/tcp, :::443->443/tcp       webserver
22a3330a256c   contentserver   "/contentserver_setu…"   35 minutes ago   Up 16 seconds (healthy)   0.0.0.0:9000->9000/tcp, :::9000->9000/tcp   contentserver
2cb77aaeb272   dbserver        "/usr/local/sbin/doc…"   35 minutes ago   Up 16 seconds (healthy)   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp   dbserver
```
