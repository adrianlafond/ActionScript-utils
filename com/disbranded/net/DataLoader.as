package com.disbranded.net {
	import flash.net.*;
	import flash.events.*;
	
	
	/**
	 * @see flash.net.URLLoader#complete
	 * 
	 * @eventType flash.events.Event.COMPETE
	 */
	[Event("complete", type="flash.events.Event")]
	
	/**
	 * @see flash.net.URLLoader#open
	 * 
	 * @eventType flash.events.Event.OPEN
	 */
	[Event("open", type="flash.events.Event")]

	
	/**
	 * @see flash.net.URLLoader#ioError
	 * 
	 * @eventType flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event("ioError", type="flash.events.IOErrorEvent")]
	
	/**
	 * @see flash.net.URLLoader#httpStatus
	 * 
	 * @eventType flash.events.HTTPStatusEvent.HTTP_STATUS
	 */
	[Event("httpStatus", type="flash.events.HTTPStatusEvent")]
	
	/**
	 * @see flash.net.URLLoader#progress
	 * 
	 * @eventType flash.events.ProgressEvent.PROGRESS
	 */
	[Event("progress", type="flash.events.ProgressEvent")]
	
	/**
	 * @see flash.net.URLLoader#securityError
	 * 
	 * @eventType flash.events.SecurityErrorEvent.SECURITY_ERROR
	 */
	[Event("securityError", type="flash.events.SecurityErrorEvent")]


	public class DataLoader extends EventDispatcher {
		
		protected var _urlLoader:URLLoader;
		protected var _bytesLoaded:Number = 0;
		protected var _bytesTotal:Number = 0;
		

		/**
		 * Designed to be a bit simpler than flash.display.URLLoader, which it wraps.
		 * 
		 * @see flash.display.URLLoader  
		 */
		public function DataLoader() {
			super();
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE, loadEvent);
			_urlLoader.addEventListener(Event.OPEN, loadEvent);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loadIOError);
			_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, loadHTTPStatus);
			_urlLoader.addEventListener(ProgressEvent.PROGRESS, loadProgress);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadSecurityError);
		}
		
		
		/**
		 * Access to the actual URLLoader instance.
		 */
		public function get urlLoader():URLLoader {
			return _urlLoader;
		}
		
		
		public function get bytesLoaded():Number {
			return _bytesLoaded;
		}
		
		public function get bytesTotal():Number {
			return _bytesTotal;
		}
		
		/**
		 * @see flash.net.URLLoader#data
		 */
		public function get data():* {
			return _urlLoader ? _urlLoader.data : null;
		}

		/**
		 * @see flash.net.URLLoader#dataFormat
		 */
		public function get dataFormat():String {
			return _urlLoader ? _urlLoader.dataFormat : null;
		}
		/**
		 * @private
		 */
		public function set dataFormat(format:String):void {
			if (_urlLoader) {
				_urlLoader.dataFormat = format;
			}
		}
		
		
		/**
		 * For when you just need to load a URL. If you need to load
		 * an URLRequest, use loadRequest().
		 * 
		 * @param path String
		 * 
		 * @see #loadRequest()
		 */
		public function load(path:String):void {
			loadRequest(new URLRequest(path));
		}
		
		/**
		 * For when you really do need to use an URLRequest.
		 * 
		 * @param urlR URLRequest
		 * 
		 * @see #load()
		 */
		public function loadRequest(urlR:URLRequest):void {
			try {
				_urlLoader.load(urlR);
			} catch (e:Error) {}
		}
		
		
		/**
		 * Cancels any load in progress and suppresses any errors.
		 */
		public function cancelLoad():void {
			try {
				_urlLoader.close();
			} catch (e:Error) {}
		}
		
		
		/**
		 * Calls cancelLoad(), removes all event listeners, and destroys the URLLoader instance.
		 * 
		 * @see #cancelLoad()
		 */
		public function destroy():void {
			if (_urlLoader) {
				cancelLoad();
				_urlLoader.removeEventListener(Event.COMPLETE, loadEvent);
				_urlLoader.removeEventListener(Event.OPEN, loadEvent);
				_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, loadIOError);
				_urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, loadHTTPStatus);
				_urlLoader.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
				_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadSecurityError);
				_urlLoader = null;
			}
		}
		
		
		/*
		* private/protected methods
		*/
		protected function loadEvent(evt:Event):void {
			evt.stopPropagation();
			if (willTrigger(evt.type)) {
				var newEvent:Event = new Event(evt.type, evt.bubbles, evt.cancelable);
				dispatchEvent(newEvent);
			}
		}		

		protected function loadIOError(evt:IOErrorEvent):void {
			evt.stopPropagation();
			if (willTrigger(evt.type)) {
				var newEvent:IOErrorEvent = new IOErrorEvent(evt.type, evt.bubbles, evt.cancelable, evt.text);
				dispatchEvent(newEvent);
			}
		}

		protected function loadHTTPStatus(evt:HTTPStatusEvent):void {
			evt.stopPropagation();
			if (willTrigger(evt.type)) {
				var newEvent:HTTPStatusEvent = new HTTPStatusEvent(evt.type, evt.bubbles, evt.cancelable, evt.status);
				dispatchEvent(newEvent);
			}
		}

		protected function loadProgress(evt:ProgressEvent):void {
			_bytesLoaded = evt.bytesLoaded;
			_bytesTotal = evt.bytesTotal;
			evt.stopPropagation();
			if (willTrigger(evt.type)) {
				var newEvent:ProgressEvent = new ProgressEvent(evt.type, evt.bubbles, evt.cancelable, evt.bytesLoaded, evt.bytesTotal);
				dispatchEvent(newEvent);
			}
		}

		protected function loadSecurityError(evt:SecurityErrorEvent):void {
			evt.stopPropagation();
			if (willTrigger(evt.type)) {
				var newEvent:SecurityErrorEvent = new SecurityErrorEvent(evt.type, evt.bubbles, evt.cancelable, evt.text);
				dispatchEvent(newEvent);
			}
		}		
	}
}
