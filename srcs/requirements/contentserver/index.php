<!DOCTYPE html>
<html>
    <head>
        <title>Pagina de prueba</title>
    </head>
    <body>

        <?php
            echo "Hello Inception World! Current timestamp: " . date("Y-m-d H:i:s T") . " (From PHP-FPM LMCD)";
            error_log("--- DEBUGGING WP CONSTANTS ---");
            error_log("DB_HOST constant: '" . (defined('DB_HOST') ? DB_HOST : 'NOT DEFINED') . "'");
            error_log("DB_USER constant: '" . (defined('DB_USER') ? DB_USER : 'NOT DEFINED') . "'");
            error_log("DB_NAME constant: '" . (defined('DB_NAME') ? DB_NAME : 'NOT DEFINED') . "'");
            error_log("DB_PASSWORD constant: '" . (defined('DB_PASSWORD') ? DB_PASSWORD : 'NOT DEFINED') . "'");
            error_log("--- END DEBUGGING WP CONSTANTS ---");
        ?>
        <?php
        /**
         * Front to the WordPress application. This file doesn't do anything, but loads
         * wp-blog-header.php which does and tells WordPress to start the ball rolling.
         *
         * @package WordPress
         */

        /**
         * Tells WordPress to load the WordPress theme and output it.
         *
         * @var bool
         */
        define( 'WP_USE_THEMES', true );

        /** Loads the WordPress Environment and Template */
        require __DIR__ . '/wp-blog-header.php';

        echo "Database Name (DB_HOST): " . DB_HOST . "<br>";
        echo "Database Name (DB_NAME): " . DB_NAME . "<br>";
        echo "Database Name (DB_USER): " . DB_USER . "<br>";
        echo "Database Name (DB_PASSWORD): " . DB_PASSWORD . "<br>";
 
        ?>

    </body>
</html>



