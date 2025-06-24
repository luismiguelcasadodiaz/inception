<!DOCTYPE html>
<html>
    <head>
        <title>Pagina de prueba</title>
    </head>
    <body>

        <?php
            echo "Hello Inception World! Current timestamp: " . date("Y-m-d H:i:s T") . " (From PHP-FPM LMCD)";
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

        // --- ADD YOUR CODE HERE TO PRINT DB_NAME ---
        if ( defined('DB_NAME') ) {
            echo "Database Name (DB_NAME): " . DB_NAME . "<br>";
        } else {
            echo "DB_NAME is not defined.<br>";
        }
        // ------------------------------------------

        ?>

    </body>
</html>



