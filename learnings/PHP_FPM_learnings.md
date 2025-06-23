# php-fpm

PHP-FPM stands for PHP FastCGI Process Manager. It's an alternative, highly efficient implementation of PHP's FastCGI (Fast Common Gateway Interface) that is specifically designed to handle PHP requests, particularly for high-traffic websites.


Here's a breakdown of what that means and why it's important:

## 1. PHP and Web Servers:

+ **PHP**: PHP is a server-side scripting language used to create dynamic web content. When you visit a website, if it uses PHP, the web server (like Nginx or Apache) needs a way to "understand" and execute that PHP code.

+ **Web Servers**: Web servers are responsible for serving web content (HTML, CSS, images, etc.) to users. They are not inherently designed to execute PHP code directly.
## 2. The Role of FastCGI:

+ **CGI (Common Gateway Interface)**: This was an early method for web servers to interact with external programs (like PHP). For **every request**, a **new PHP process** would be started, execute the script, and then terminate. This was inefficient, especially under high load, due to the overhead of constantly starting and stopping processes.

+ **FastCGI**: FastCGI was developed as an improvement over CGI. Instead of starting a new process for each request, FastCGI uses **long-running processes** (called "workers" or "child processes"). The web server communicates with these persistent processes to handle PHP requests. This significantly reduces overhead and improves performance.


## 3. What PHP-FPM Adds:

PHP-FPM is an advanced and robust implementation of FastCGI for PHP, offering several key features and advantages:

### Process Management: 
This is the "Process Manager" part of its name. PHP-FPM acts as a daemon that manages a pool of PHP worker processes.
+ **Master Process**: A single master process oversees the worker processes.
+ **Worker Processes** (Child Processes): These are the actual PHP interpreters that execute your PHP code. PHP-FPM can dynamically create or destroy these workers based on the current load, optimizing resource usage.

+ **Worker Pools**: PHP-FPM allows you to set up multiple "pools" of workers, each with its own configuration (e.g., different user IDs, group IDs, php.ini settings, resource limits). This is incredibly useful for hosting multiple websites on a single server, providing isolation and better resource control for each site.

### Performance Improvements:
+ **Reduced Overhead**: By reusing PHP processes, it avoids the constant startup/teardown overhead of traditional CGI.
+ **Opcode Caching**: PHP-FPM works very well with opcode caches (like OPcache), which store compiled PHP code in memory, eliminating the need to re-read and re-compile scripts for every request. This is a massive performance boost.
+ **Efficient Resource Utilization**: Dynamic process management helps prevent the server from being overwhelmed by too many PHP processes, ensuring stability and better use of memory and CPU.

### Stability and Reliability: 
PHP-FPM provides features like graceful restarts (allowing updates without dropping requests), error logging, and the ability to detect and respawn failed workers, contributing to a more stable environment.

### Advanced Features:
+ **Slowlog**: Helps identify slow-running PHP scripts by logging their execution time and even backtraces.
+ `fastcgi_finish_request()`: A special function that allows PHP to send a response to the client and then continue with time-consuming tasks in the background.
+ Configurable `stdout` and `stderr` logging.
+ Ability to restrict IP addresses from which requests can come.

## 4. How it Works (Simplified):

+ 1.- Web Server Receives Request: A user's browser sends a request to your web server (e.g., Nginx or Apache).
+ 2.- Web Server Forwards to PHP-FPM: If the request is for a PHP file, the web server doesn't execute it directly. Instead, it acts as a proxy and forwards the request to PHP-FPM (typically via a TCP/IP socket or a Unix socket).

+ 3.- PHP-FPM Assigns to Worker: PHP-FPM's master process receives the request and assigns it to an available worker process from its pool.
+ 4.- Worker Executes PHP: The worker process executes the PHP script. If an opcode cache is in use, it will use the cached version if available, otherwise, it will compile and execute the script.
+ 5.- Response Sent Back: The PHP worker sends the output (HTML, JSON, etc.) back to the web server.
+ 6.- Web Server Delivers to Browser: The web server then sends the final response to the user's browser.



# php-fpm logs
By default, PHP-FPM worker processes send their stdout and stderr to /dev/null (meaning **you wouldn't see them**). `catch_workers_output = yes` redirects this output to the main PHP-FPM error log. Since the main error log is typically sent to stderr by PHP-FPM itself when running in the foreground, this is a bridge to Docker's logging mechanism.

; Log PHP errors to a specific file for this pool.
php_admin_value[error_log] = /var/log/php-fpm84_error.log
; Enable logging of errors.
php_admin_flag[log_errors] = on
