package com.disbranded.media {
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.errors.*;


   /**
	* Extends flash.media.Sound to include methods and properties normally accessed only through
	* the instantiation and use of additional classes, such as SoundTransform and SoundChannel.
	* 
	* <p>Because it extends Sound, it can be used virtually anywhere that a Sound can be used.</p>
	*/
	public class DSound extends Sound {

		

		protected var _sound:Sound = null;
		
		protected var _channel:SoundChannel;
		
		protected var _transform:SoundTransform;
		
		protected var _position:Number = 0;
		
		protected var _playing:Boolean = false;
		
		
		
		

	
	   /**
		* @param stream If not set, <code>sound</code> must be set.
		* @param context
		* 
		* @see #sound
		*/
		public function DSound(stream:URLRequest = null, context:SoundLoaderContext = null) {
			if (stream != null) {
				super(stream, context);
			}
			_transform = new SoundTransform();
		}
		
	
	
	   /**
		* If param <code>stream</code> is not set in the constructor, then a Sound must be set.
		* 
		* @see #DSound()
		*/
		public function get sound():Sound {
			return (_sound==null) ? this : _sound;
		}		
	   /**
		* @private
		*/
		public function set sound(s:Sound):void {
			if (_sound == null) {
				_sound = s;
			}
		}




		override public function load(stream:URLRequest, context:SoundLoaderContext = null):void {
			if (_sound == null) {
				super.load(stream, context);
				addEventListener(IOErrorEvent.IO_ERROR, eventIOError, false, 0, true);
			} else {
				_sound.addEventListener(Event.COMPLETE, eventComplete, false, 0, true);
				_sound.addEventListener(Event.OPEN, eventOpen, false, 0, true);
				_sound.addEventListener(Event.ID3, eventID3, false, 0, true);
				_sound.addEventListener(ProgressEvent.PROGRESS, eventProgress, false, 0, true);
				_sound.addEventListener(IOErrorEvent.IO_ERROR, eventIOError, false, 0, true);
				try {
					_sound.load(stream, context);
				} catch (e:Error) {
					trace(e.message);
				}
			}

		}
		
		
		protected function eventComplete(evt:Event):void {
			evt.stopPropagation();
			if (willTrigger(evt.type)) {
				dispatchEvent(new Event(evt.type, evt.bubbles, evt.cancelable));
			}			
		}
		
		
		protected function eventOpen(evt:Event):void {
			evt.stopPropagation();
			if (willTrigger(evt.type)) {
				dispatchEvent(new Event(evt.type, evt.bubbles, evt.cancelable));
			}
		}
		
		
		protected function eventProgress(evt:ProgressEvent):void {
			evt.stopPropagation();
			if (willTrigger(evt.type)) {
				dispatchEvent(new ProgressEvent(evt.type, evt.bubbles, evt.cancelable, evt.bytesLoaded, evt.bytesTotal));
			}			
		}
		
		
		protected function eventID3(evt:Event):void {
			evt.stopPropagation();
			if (willTrigger(evt.type)) {
				dispatchEvent(new Event(evt.type, evt.bubbles, evt.cancelable));
			}
		}
		
		
		protected function eventIOError(evt:IOErrorEvent):void {
			evt.stopPropagation();
			try {
				_sound.close();
			} catch (e:IOError) {}
			if (willTrigger(evt.type)) {
				dispatchEvent(new IOErrorEvent(evt.type, evt.bubbles, evt.cancelable, evt.text));
			}
		}
		
		
		
		
		override public function play(startTime:Number = -1, loops:int = 0, sndTransform:SoundTransform = null):SoundChannel {
			startTime = (startTime < 0) ? _position : startTime;
			_position = startTime;
			if (_channel) {
				_channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
				if (isPlaying) {
					_channel.stop();
				}
			}
			_playing = true;
			if (_sound == null) {
				_channel = super.play(startTime, loops, sndTransform);
			} else {
				_channel = _sound.play(startTime, loops, sndTransform);
			}			
			_channel.addEventListener(Event.SOUND_COMPLETE, soundComplete, false, 0, true);
			if (sndTransform != null) {
				soundTransform = sndTransform;
			} else {
				addTransform();
			}
			return _channel;
		}
		
		
		
		/**
		 * Stops the sound, rewinding to position 0.
		 * 
		 * @see #pause()
		 * @see #position
		 */
		public function stop():void {
			if (_channel && isPlaying) {
				_playing = false;
				_position = 0;
				_channel.stop();
			}
		}
		
		/**
		 * Pauses the sound, holding the current position.
		 * 
		 * @see #stop()
		 * @see #position
		 */
		public function pause():void {
			if (_channel && isPlaying) {
				_playing = false;
				_position = _channel.position;
				_channel.stop();
			}
		}
		

		
		protected function soundComplete(evt:Event):void {
			_playing = false;
			dispatchEvent(new Event(Event.SOUND_COMPLETE, evt.bubbles, evt.cancelable));
		}
		
		
		
		/**
		 * Returns <code>true</code> if playing, <code>false</code> is paused or stopped.
		 */
		public function get isPlaying():Boolean {
			return _playing;
		}


		override public function get id3():ID3Info {
			return sound.id3;
		}		
		
		override public function get bytesLoaded():uint {
			return sound.bytesLoaded;
		}
		
		override public function get bytesTotal():int {
			return sound.bytesTotal;
		}

		override public function get isBuffering():Boolean {
			return sound.isBuffering;
		}
		
		override public function get length():Number {
			return sound.length;
		}
		
		override public function get url():String {
			return sound.url;
		}

		
		
		/**
		 * DSound contains its own SoundChannel instance.
		 * 
		 * @see flash.media.SoundChannel
		 */
		public function get soundChannel():SoundChannel {
			return _channel;
		}
		
		/**
		 * @see flash.media.SoundChannel#position
		 */
		public function get position():Number {
			if (_channel) {
		 		return isPlaying ? _channel.position : _position;
			}
			return 0;
		}		
		
		/**
		 * @see flash.media.SoundChannel#leftPeak
		 */
		public function get leftPeak():Number {
			return (_channel) ? _channel.leftPeak : 0;
		}
		
		/**
		 * @see flash.media.SoundChannel#rightPeak
		 */
		public function get rightPeak():Number {
			return (_channel) ? _channel.rightPeak : 0;
		}
		
		
		
		
		/**
		 * DSound contains its own SoundTransform instance.
		 * 
		 * @see flash.media.SoundTransform
		 */
		public function get soundTransform():SoundTransform {
			return _transform;
		}		
		/**
		 * @private
		 */
		public function set soundTransform(st:SoundTransform):void {
			_transform = st;
			addTransform();
		}
		
		
		
		
		/**
		 * @see flash.media.SoundTransform#volume
		 */
		public function get volume():Number {
			return _transform.volume;
		}
		/**
		 * @private
		 */
		public function set volume(n:Number):void {
			_transform.volume = Math.min(1, Math.max(0, n));
			addTransform();
		}
		
		/**
		 * @see flash.media.SoundTransform#pan
		 */
		public function get pan():Number {
			return _transform.pan;
		}
		/**
		 * @private
		 */
		public function set pan(n:Number):void {
			_transform.pan = Math.min(1, Math.max(-1, n));
			addTransform();
		}
		
		
		/**
		 * @see flash.media.SoundTransform#leftToLeft
		 */
		public function get leftToLeft():Number {
			return _transform.leftToLeft;
		}
		/**
		 * @private
		 */
		public function set leftToLeft(n:Number):void {
			_transform.leftToLeft = Math.min(1, Math.max(0, n));
			addTransform();
		}
		
		/**
		 * @see flash.media.SoundTransform#leftToRight
		 */
		public function get leftToRight():Number {
			return _transform.leftToRight;
		}
		/**
		 * @private
		 */
		public function set leftToRight(n:Number):void {
			_transform.leftToRight = Math.min(1, Math.max(0, n));
			addTransform();
		}
		
		/**
		 * @see flash.media.SoundTransform#rightToLeft
		 */
		public function get rightToLeft():Number {
			return _transform.rightToLeft;
		}
		/**
		 * @private
		 */
		public function set rightToLeft(n:Number):void {
			_transform.rightToLeft = Math.min(1, Math.max(0, n));
			addTransform();
		}
		
		/**
		 * @see flash.media.SoundTransform#rightToRight
		 */
		public function get rightToRight():Number {
			return _transform.rightToLeft;
		}
		/**
		 * @private
		 */
		public function set rightToRight(n:Number):void {
			_transform.rightToLeft = Math.min(1, Math.max(0, n));
			addTransform();
		}
		
		
		protected function addTransform():void {
			if (_channel != null) {
				_channel.soundTransform = _transform;	
			}
		}

		
		
		
		override public function close():void {
			removeEventListener(IOErrorEvent.IO_ERROR, eventIOError);
			if (_sound != null) {
				_sound.removeEventListener(Event.COMPLETE, eventComplete);
				_sound.removeEventListener(Event.OPEN, eventOpen);
				_sound.removeEventListener(Event.ID3, eventID3);
				_sound.removeEventListener(ProgressEvent.PROGRESS, eventProgress);
				_sound.removeEventListener(IOErrorEvent.IO_ERROR, eventIOError);
				try {
					_sound.close();
				} catch (e:IOError) {}
			} else {
				try {
					super.close();
				} catch (e:IOError) {}
			}
			_sound = null;
		}

	}
}
