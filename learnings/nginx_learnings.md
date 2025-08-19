# ssl certificate

Inception project entrypoint is port 443 at webserver container. 

That requiress a ssl certification. This is the standard instruction to create a ssl certificate


```bash
mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./certs/nginx.key -out ./certs/nginx.crt -subj "/C=ES/ST=Catalonia/L=Barcelona/O=42barcelona.com/CN=10.12.250.80"
```

As it requires the virtual machine IP, that is assigned by DHCP, i created a script that runs at bootime.

I saved the **executable** script at `/etc/local.d/generate_cert.start` and activate it at boot time with `rc-update add local default`

You can verify certificate content with this command

`-nodes` is required to allow nginx auutomatically use the certificated wihtout a password.
`-days` to define validy period.
`-newkey` forces to create a new private key if does not exist. if exists openssl refuses to create a new private key. 

```bash
openssl x509 -in /ruta/nginx.crt -text -noout
```


# one preocess per container
The daemon off; directive in Nginx, especially when used in containerized environments like Docker, significantly enhances robustness by aligning with the "one process per container" philosophy and simplifying process management. Here's why it adds robustness:

### 1.- Proper Process Supervision:

+ In a **traditional** server setup, Nginx typically runs as a daemon, meaning **it forks** into a background process, detaching from the shell that launched it. The original shell then exits. This makes it difficult for traditional process supervisors (like systemd, supervisord, or Kubernetes) to directly monitor and manage the main Nginx process. They often rely on PID files or other mechanisms to track the daemon.
    
+ With daemon off;, Nginx **runs in the foreground**. This means the Nginx master process itself remains **as the primary process (PID 1)** within the container. A container orchestration system (Docker, Kubernetes, etc.) can then directly monitor this PID 1. If Nginx crashes, the container's main process exits, and the **orchestration system immediately detects the failure and can restart the container**, ensuring high availability. This is a much more robust and reliable way to handle Nginx's lifecycle.

### 2.- Simplified Logging:

+ When Nginx runs in the foreground, its **logs** (access and error logs) are typically directed to standard output (stdout) and standard error (stderr).
    
+ In containerized environments, these streams are **captured by the container runtime** and can be easily forwarded to centralized logging systems (e.g., ELK stack, Splunk, cloud logging services). This makes it much **easier to collect, aggregate, and analyze Nginx logs**, which is crucial for troubleshooting, monitoring performance, and identifying security issues. If Nginx were to daemonize, you'd need additional configuration to send logs to stdout/stderr or mount volumes for log files, adding complexity.

### 3.- Graceful Shutdowns:

+ When an orchestration system needs to stop or restart a container, it sends signals (like SIGTERM) to the PID 1 process. If Nginx is running in the foreground (daemon off;), it directly receives these signals and can perform a graceful shutdown (e.g., finish serving current requests before exiting).
    
+ If Nginx daemonizes, the signal might only be received by the initial shell process that spawned Nginx, not the actual Nginx master process, leading to abrupt terminations and potential data loss or connection issues.

### 4.- No PID File Issues:

+ When Nginx runs as a daemon, it typically writes a PID file to track its master process ID. In container environments, managing PID files can be tricky due to the ephemeral nature of containers and potential volume mapping complexities.

+ By running in the foreground, Nginx doesn't need to create a PID file, **eliminating a potential source of configuration or permission-related issues**.


# PHP requests
inside nginx.conf `fastcgi_pass` directive tells Nginx where to send PHP requests for processing.

```conf
# Forward requests to the contentserver container's IP and PHP-FPM port
fastcgi_pass 192.168.1.3:9000;
```

That directive goes inside a server {} directive specifiying *.php treatment `location ~* \.php$ `

You'd typically use `~*` when you want to handle file extensions or parts of a URL without worrying about the client's capitalization otherwise you use `~` only.


```conf
    server {
        root /www; 
        location ~* \.php$ {
        # Ensure the file exists before passing to PHP-FPM
        #try_files $uri =404;

        # Forward requests to the contentserver container's IP and PHP-FPM port
        fastcgi_pass 192.168.1.3:9000;

        # Include standard FastCGI parameters
        include fastcgi_params;


        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        }
    }
```

Set the SCRIPT_FILENAME to the actual path in the contentserver container 
This tells PHP-FPM the absolute path to the PHP script it needs to execute within its own container. 
`$document_root` will be /www. $fastcgi_script_name will be the requested PHP file (e.g., /index.php).


The fastcgi_param SCRIPT_FILENAME directive inside a location ~* \.php$ {} block is one of the **most critical pieces of configuration** for getting Nginx to work with PHP-FPM.

It tells PHP-FPM (the FastCGI Process Manager) exactly which PHP script file it needs to execute for the current request.

Let's break down its components and what it means:

fastcgi_param: This is an Nginx directive used to **define a parameter that will be passed to the FastCGI server** (in your case, PHP-FPM). FastCGI uses these parameters (similar to environment variables) to communicate request-specific information.

SCRIPT_FILENAME: This is a standard FastCGI variable name (and also an environment variable that PHP scripts commonly access via $_SERVER['SCRIPT_FILENAME']). It's expected by PHP-FPM to **specify the absolute path to the PHP script** that PHP-FPM should process.

`$document_root`: This is an Nginx built-in variable. It dynamically expands to the value of the `root` directive that is active for the current request. nginx.conf has `root /www`;, so `$document_root` will evaluate to `/www`.

`$fastcgi_script_name`: This is another Nginx built-in variable. It expands to the URI of the requested PHP script. For example:

+ If the request is /index.php, $fastcgi_script_name will be /index.php.
+ If the request is /blog/post.php, $fastcgi_script_name will be /blog/post.php.

`$document_root$fastcgi_script_name`: When combined, this creates the full absolute path to the PHP script that Nginx wants PHP-FPM to execute.

+ For a request to https://10.12.250.80/index.php, with `$document_root = /www` and `$fastcgi_script_name = /index.php` then `SCRIPT_FILENAME` becomes `/www/index.php`

### Why is this so important?

+ 1.- PHP-FPM Needs the File Path: Nginx itself doesn't execute PHP code. It acts as a reverse proxy, passing the request to PHP-FPM. PHP-FPM needs to know which PHP file on its own filesystem it should load and run. `SCRIPT_FILENAME` provides this crucial piece of information.
<br>
+ 2.-Mapping Between Containers (Inception case): We have two separate containers: webserver(nginx) and contentserver(PHP-FPM). While Nginx's root directive tells Nginx where to find files if it were serving them itself, the SCRIPT_FILENAME parameter tells PHP-FPM where to find the file within its own container's file system. 
  <br>
    + It's vital that the path constructed by `$document_root$fastcgi_script_name` (e.g., /www/index.php) is the actual path to the PHP file **inside the PHP-FPM container**. If these paths don't align (e.g., Nginx thinks the root is /www but PHP-FPM expects files in /var/www/html), PHP-FPM will return a "No input file specified" error or similar. 
    <br>
    + I commented `try_files`. That avoids nginx looks for *.php files it does not have, ensuring Nginx blindly passes the request and relies on PHP-FPM to find the file at /www/index.php.
<br>
+ 3.- Security and Correct Execution: This parameter **prevents** PHP-FPM from executing **arbitrary files** that it shouldn't. It explicitly tells it the script to run based on the request URI and the defined document root.

### location blocks order matters
The order of your location blocks for static files, PHP, and the general fallback 