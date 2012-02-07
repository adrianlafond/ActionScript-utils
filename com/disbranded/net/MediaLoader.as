package com.disbranded.net {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;

	/**
	 * @see flash.display.LoaderInfo#complete
	 * 
	 * @eventType flash.events.Event.COMPETE
	 */
	[Event("complete", type="flash.events.Event")]
	
	/**
	 * @see flash.display.LoaderInfo#init
	 * 
	 * @eventType flash.events.Event.INIT
	 */
	[Event("init", type="flash.events.Event")]
	
	/**
	 * @see flash.display.LoaderInfo#open
	 * 
	 * @eventType flash.events.Event.OPEN
	 */
	[Event("open", type="flash.events.Event")]
	
	/**
	 * @see flash.display.LoaderInfo#unload
	 * 
	 * @eventType flash.events.Event.UNLOAD
	 */
	[Event("unload", type="flash.events.Event")]
	
	/**
	 * @see flash.display.LoaderInfo#ioError
	 * 
	 * @eventType flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event("ioError", type="flash.events.IOErrorEvent")]
	
	/**
	 * @see flash.display.LoaderInfo#httpStatus
	 * 
	 * @eventType flash.events.HTTPStatusEvent.HTTP_STATUS
	 */
	[Event("httpStatus", type="flash.events.HTTPStatusEvent")]
	
	/**
	 * @see flash.display.LoaderInfo#progress
	 * 
	 * @eventType flash.events.ProgressEvent.PROGRESS
	 */
	[Event("progress", type="flash.events.ProgressEvent")]
	


	public class MediaLoader extends EventDispatcher {


		protected var _loader:Loader;
		protected var _bytesLoaded:Number = 0;
		protected var _bytesTotal:Number = 0;


	
		/**
		 * Because some things should be simple.
		 * 
		 * <p>Only fires events that you are listening for. So will not fire an IOErrorEvent if the user
		 * exits the page while something is loading.</p>
		 */
		public function MediaLoader() {
			super();
			activate();
		}
		
		
		/**
		 * Access to the actual Loader instance.
		 * 
		 * @see flash.display.Loader
		 */
		public function get loader():Loader {
			return _loader;
		}
		
		/**
		 * Access to the actual LoaderInfo instance.
		 * 
		 * @see flash.display.LoaderInfo
		 */
		public function get loaderInfo():LoaderInfo {
			return _loader.contentLoaderInfo;
		}
		
		
		/**
		 * Access to the actual Loader.content.
		 * 
		 * @see flash.display.Loader#content
		 */
		public function get content():DisplayObject {
			return _loader.content;
		}
		

		public function get bytesLoaded():Number {
			return _bytesLoaded;
		}
		
		public function get bytesTotal():Number {
			return _bytesTotal;
		}
		

		/**
		 * @param path String, so you don't need an URLRequest()
		 * @param context LoaderContext 
		 * 
		 * @see #loadRequest()
		 */
		public function load(path:String, context:LoaderContext = null):void {
			loadRequest(new URLRequest(path), context);
		}
		
		/**
		 * If you need to load a URLRequest, call this method instead of load().
		 * 
		 * @param urlR URLRequest 
		 * @param context LoaderContext 
		 * 
		 * @see #load()
		 */
		public function loadRequest(urlR:URLRequest, context:LoaderContext = null):void {
			try {
				_loader.load(urlR, context);
			} catch (e:Error) {}
		}
		
		
		/**
		 * Call cancelLoad(), unload(), and deactivate().
		 * 
		 * @see #cancelLoad()
		 * @see unload()
		 * @see deactivate() 
		 */
		public function destroy():void {
			if (_loader) {
				cancelLoad();
				unload();
				deactivate();
			}
		}
		
		
		/**
		 * Closes any load in progress. Suppresses errors.
		 * 
		 * @see flash.display.Loader#close()
		 */
		public function cancelLoad():void {
			_bytesLoaded = 0;
			_bytesTotal = 0;
			try {
				_loader.close();
			} catch (e:Error) {}
		}
		
		
		/**
		 * Unlike Loader.unload(), suppressed errors. Just unload() and don't gimme no lip.
		 * 
		 * @see flash.display.Loader#unload()
		 */
		public function unload():void {
			try {
				_loader.unload();
			} catch (e:Error) {}
		}
		
		/**
		 * Suppresses errors. Call only if you are thoroughly done with Loader.content.
		 * 
		 * @param garbagecollect Boolean, default is true.
		 * 
		 * @see flash.display.Loader.unloadAndStop()
		 * 
	     * @playerversion Flash 10
		 */
		public function unloadAndStop(garbagecollect:Boolean = true):void {
			try {
				if (_loader.hasOwnProperty("unloadAndStop")) {
					_loader["unloadAndStop"](garbagecollect);
				}
			} catch (e:Error) {}
		}
		
		
		/**
		 * Probably never needs to be called as it is called internally.
		 * 
		 * <p>Sets up event listeners.</p>
		 */
		public function activate():void {
			if (_loader != null) return;
			_loader = new Loader();
			loaderInfo.addEventListener(Event.COMPLETE, loadEvent);
			loaderInfo.addEventListener(Event.INIT, loadEvent);
			loaderInfo.addEventListener(Event.OPEN, loadEvent);
			loaderInfo.addEventListener(Event.UNLOAD, loadEvent);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadIOError);
			loaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, loadHTTPStatus);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress);
		}		

		/**
		 * Probably never needs to be called as it is called internally.
		 * 
		 * Calling destroy() is better.
		 * 
		 * @see #destroy()
		 */
		public function deactivate():void {
			if (_loader == null) return;
			cancelLoad();
			loaderInfo.removeEventListener(Event.COMPLETE, loadEvent);
			loaderInfo.removeEventListener(Event.INIT, loadEvent);
			loaderInfo.removeEventListener(Event.OPEN, loadEvent);
			loaderInfo.removeEventListener(Event.UNLOAD, loadEvent);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadIOError);
			loaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, loadHTTPStatus);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			_loader = null;
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
    }
}

