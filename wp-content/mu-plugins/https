<?php
/**
 * Plugin Name: HTTPS
 * Description: Fixes and improves HTTPS support.
 * Version:     1.0.0
 * Author:      log.OSCON, Lda.
 * Author URI:  https://log.pt/
 * License:     GPL-2.0+
 */

/**
 * Force URLs in srcset attributes into HTTPS scheme.
 *
 * @param     array    $sources    Source data to include in the 'srcset'.
 * @return    array                Possibly-modified source data.
 */
\add_filter( 'wp_calculate_image_srcset', function( $sources ) {
	foreach ( $sources as &$source ) {
		$source['url'] = \set_url_scheme( $source['url'], \is_ssl() ? 'https' : 'http' );
	}
	return $sources;
} );
