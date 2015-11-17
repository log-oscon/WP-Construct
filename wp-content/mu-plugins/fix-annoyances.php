<?php
/**
 * Fixes WordPress annoyances.
 *
 * @link    http://log.pt
 * @since   1.0.0
 * @package Fix_Annoyances
 *
 * @wordpress-plugin
 * Plugin Name: Fix WP Annoyances
 * Plugin URI:  http://log.pt/
 * Description: Fixes annoyances in WordPress.
 * Version:     1.0.0
 * Author:      log.OSCON, Lda.
 * Author URI:  http://log.pt/
 */


/**
 * Dequeue Jetpack junk.
 */
\add_action( 'wp_enqueue_scripts', function () {
    \wp_dequeue_script( 'devicepx' );
}, 99 );


/**
 * Go home, Jetpack, you're drunk.
 */
\add_action( 'init', function () {
    \add_action( 'jetpack_holiday_chance_of_snow', '__return_null' );
} );


/**
 * Autoptimize: Do not concatenate inline assets.
 */
add_filter( 'autoptimize_css_include_inline', '__return_false' );
add_filter( 'autoptimize_js_include_inline', '__return_false' );


/**
 * Excludes JavaScript assets from optimization.
 * @param  string $exclude JavaScript assets to exclude in a comma-separated list.
 * @return string          Filtered JavaScript assets to exclude in a comma-separated list.
 */
\add_filter( 'autoptimize_filter_js_exclude', function ( $exclude ) {
    return implode( ',', array(
        'jquery.js',
        $exclude,
    ) );
} );


/**
 * Excludes CSS assets from optimization.
 * @param  string $exclude CSS assets to exclude in a comma-separated list.
 * @return string          Filtered CSS assets to exclude in a comma-separated list.
 */
\add_filter( 'autoptimize_filter_css_exclude', function ( $exclude ) {
    return implode( ',', array(
        'customize-support',
        $exclude,
    ) );
} );