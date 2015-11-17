<?php
/**
 * @wordpress-plugin
 * Plugin Name:       Autoload Composer Dependencies
 * Description:       Autoloads Composer dependencies at project root.
 * Version:           1.0.0
 * Author:            Luís Rodrigues
 * License:           GPL-2.0+
 * License URI:       http://www.gnu.org/licenses/gpl-2.0.txt
 */

if ( file_exists( ABSPATH . '/vendor/autoload.php' ) ) {
    require_once ABSPATH . '/vendor/autoload.php';
}
