/**
* com.disbranded.net.href
*
* 2008-11-17 / Adrian Lafond
*/


package com.disbranded.net {
    import flash.net.*;

	/**
	 * Because navigateToURL() and URLRequest() are too much work just
	 * to make a link work.
	 * 
	 * @param url
	 * @param target Works like HTML (default is "_self").
	 */
    public function href(url:String, target = "_self"):void {
        navigateToURL(new URLRequest(url), target);
    }

}