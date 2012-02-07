package com.disbranded.net {
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;

	/**
	 * If running in a web browser, calls a JavaScript alert(); if running in
	 * the Flash IDE, calls a trace().
	 * 
	 * @param str The string to pass to the alert().
	 */
	public function alert(str:String)	{
		if (ExternalInterface.available) {
			if (Capabilities.playerType == "ActiveX" || Capabilities.playerType == "PlugIn") {
				var url:String = "javascript:alert('";
				url += str;
				url += "')"
				navigateToURL(new URLRequest(url), "_self");
			} else if (Capabilities.playerType == "External") {
				trace(str);
			}

		}
	}
}
