# ssl certificate

Inception project entrypoint is port 443 at webserver container. 

That requiress a ssl certification. This is the standard instruction to create a ssl certificate


```bash
mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./certs/nginx.key -out ./certs/nginx.crt -subj "/C=ES/ST=Catalonia/L=Barcelona/O=42barcelona.com/CN=10.12.250.80"
```

As it requires the virtual machine IP, that is assigned by DHCP, i created a script that runs at bootime.

I saved the **executable** script at `/etc/local.d/generate_cert.start` and activate it at boot time wiht `rc-update add local default`

You can verify certificate content with this command

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