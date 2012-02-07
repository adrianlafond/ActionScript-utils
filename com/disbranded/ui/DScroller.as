///////////////////////////////////////////////////////////////////////
// com.disbranded.ui.DScroller
///////////////////////////////////////////////////////////////////////

package com.disbranded.ui {
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;

	import flash.display.*;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	//import com.pixelbreaker.ui.osx.MacMouseWheel;

	
	/**
	 *	@author Adrian Lafond / Disbranded, Inc.
	 *	@date 2010-10-01
	 */
	public class DScroller extends Sprite {
		
		
		public var mcTrack:InteractiveObject;
		public var mcThumb:InteractiveObject;
		public var mcBtnUp:InteractiveObject;
		public var mcBtnDown:InteractiveObject;
		
		protected var _track:InteractiveObject;
		protected var _thumb:InteractiveObject;
		protected var _btnUp:InteractiveObject;
		protected var _btnDown:InteractiveObject;
		
		protected var _enabled:Boolean = true;
		
		protected var _thumbBoundsRect:Rectangle;
		protected var _thumbIsProportional:Boolean = true;
		
		protected var _keyboardEnabled:Boolean = true;	
		
		protected var _width:Number;
		protected var _height:Number;
		protected var _layoutStyle:String;
		
		protected var _thumbDragging:Boolean;
		protected var _thumbOffset:Point;
		
		protected var _percent:Number = 0;
		protected var _scrollLinePercent:Number = 0.05;
		protected var _scrollPagePercent:Number = 0.25;
		
		protected var _tweenThumbMotion:Boolean = true;
		protected var _percentTarget:Number;
		
		protected var _percentTween:TweenLite;
		protected var _maxScrollDuration:Number = 1.0;
		protected var _minScrollDuration:Number = 0.2;		
		protected var _prevPercent:Number = 0;
		protected var _stopEasePercent:Number;
		
		protected var _roundThumbPosition:Boolean;
		
		protected var _direction:String;

		
		

		public function DScroller() {
			super();
			init();
		}
		
		
		protected function init():void {
			tabEnabled = tabChildren = false;
			configureObjectsOnStage();
			setInitialThumbBoundaryRect();
			determineLayoutStyle();
			direction = "vertical";
			tabChildren = false;
			setThumbProportion();
			activate();
		}
		

		/**
		 * Finds objects in the display list that correspond to DScroller parts.
		 */
		protected function configureObjectsOnStage():void {
			if (mcTrack) {
				track = mcTrack;
			}
			if (mcThumb) {
				thumb = mcThumb;
			}
			if (mcBtnUp) {
				buttonUp = mcBtnUp;
			}
			if (mcBtnDown) {
				buttonDown = mcBtnDown;
			}
		}
		
		protected function setInitialThumbBoundaryRect():void {
			if (thumbBoundsRect) return;
			if (thumb) {
				thumbBoundsRect = new Rectangle(thumb.x, thumb.y, 0, 0);				
			} else {
				thumbBoundsRect = new Rectangle(0, 0, 0, 0);
			}
		}
		
		protected function determineLayoutStyle():void {
			_layoutStyle = (buttonUp && buttonUp.y > 0 && (track || thumb)) ? DScrollerLayout.LAYOUT_MAC : DScrollerLayout.LAYOUT_NORMAL;
		}
		
		
		
		
		
		/**
		 * Reactivates events. Only needs to be called to reverse deactivate().
		 */
		public function activate():void {
			activateButtonUp();
			activateButtonDown();
			activateTrack();
			activateThumb();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			if (stage) {
				onAddedToStage();
			}		
		}
		
		protected function activateButtonUp():void {
			if (buttonUp) {
				buttonUp.addEventListener(MouseEvent.MOUSE_DOWN, onButtonUpPress, false, 0, true);
				buttonUp.addEventListener(MouseEvent.MOUSE_UP, onButtonUpRelease, false, 0, true);
			}	
		}
		
		protected function activateButtonDown():void {
			if (buttonDown) {
				buttonDown.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDownPress, false, 0, true);
				buttonDown.addEventListener(MouseEvent.MOUSE_UP, onButtonDownRelease, false, 0, true);
			}
		}
		
		protected function activateTrack():void {
			if (track) {
				track.addEventListener(MouseEvent.MOUSE_DOWN, onTrackPress, false, 0, true);
			}
		}
		
		protected function activateThumb():void {
			if (thumb) {
				thumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbPress, false, 0, true);
				thumb.addEventListener(MouseEvent.MOUSE_UP, onThumbRelease, false, 0, true);
			}
		}


		
		/**
		 * Deactivates all events.
		 */
		public function deactivate():void {
			deactivateButtonUp();
			deactivateButtonDown();
			deactivateTrack();
			deactivateThumb();
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		protected function deactivateButtonUp():void {
			if (buttonUp) {
				buttonUp.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonUpPress);
				buttonUp.removeEventListener(MouseEvent.MOUSE_UP, onButtonUpRelease);
			}
		}
		
		protected function deactivateButtonDown():void {
			if (buttonDown) {
				buttonDown.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonDownPress);
				buttonDown.removeEventListener(MouseEvent.MOUSE_UP, onButtonDownRelease);
			}
		}
		
		protected function deactivateTrack():void {
			if (track) {
				track.removeEventListener(MouseEvent.MOUSE_DOWN, onTrackPress);
			}
		}
		
		protected function deactivateThumb():void {
			if (thumb) {
				thumb.removeEventListener(MouseEvent.MOUSE_DOWN, onThumbPress);
				thumb.removeEventListener(MouseEvent.MOUSE_UP, onThumbRelease);
			}
		}
		
		
		
		protected function onButtonUpPress(evt:MouseEvent):void {
			setPercentTween(0);
		}
		
		protected function onButtonUpRelease(evt:MouseEvent):void {
			easeToStop();
		}
		
		protected function onButtonDownPress(evt:MouseEvent):void {
			setPercentTween(1);		
		}
		
		protected function onButtonDownRelease(evt:MouseEvent):void {
			easeToStop();
		}
		
		
		protected function onMouseWheel(evt:MouseEvent):void {
			if (_thumbDragging || !enabled) return;
			var p:Number = -evt.delta / 100;
			percent += p;
			if (tweenThumbMotion) {
				setPercentTween(getClosestScrollLinePercent(percent), true);
			}
			//percent += -evt.delta / 100;
		}
		
		
		protected function onTrackPress(evt:MouseEvent):void {
			if (!enabled) return;
			var p:Number;
			if (direction == "vertical") {
				p = (mouseY - thumbBoundsRect.y) / (thumbBoundsRect.height - (thumb ? thumb.height : 0));
			} else {
				p = (mouseX - thumbBoundsRect.x) / (thumbBoundsRect.width - (thumb ? thumb.width : 0));
			}
			var pageP:Number = percent + ((p > percent) ? scrollPagePercent : -scrollPagePercent);
			var slp:Number = getClosestScrollLinePercent(pageP);
			if (tweenThumbMotion) {
				setPercentTween(slp, true);
			} else {
				percent = slp;
			}
		}
		
		protected function onThumbPress(evt:MouseEvent):void {
			if (!enabled) return;
			_thumbDragging = true;
			_thumbOffset = new Point(mouseX - thumb.x, mouseY - thumb.y);
			if (stage) {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveThumbDrag, false, 0, true);
				onMouseMoveThumbDrag(null);
			}
		}
		
		protected function onThumbRelease(evt:MouseEvent):void {
			_thumbDragging = false;
			if (stage) {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveThumbDrag);
			}
			if (tweenThumbMotion) {
				setPercentTween(getClosestScrollLinePercent(percent), true);
			} else {
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		protected function onMouseMoveThumbDrag(evt:MouseEvent):void {
			var p:Number;
			if (direction == "vertical") {
				thumb.x = _thumbBoundsRect.x;
				thumb.y = Math.max(_thumbBoundsRect.y, Math.min(_thumbBoundsRect.y + _thumbBoundsRect.height - thumb.height, mouseY - _thumbOffset.y));
				p = (thumb.y - _thumbBoundsRect.y) / ((_thumbBoundsRect.height - thumb.height) - _thumbBoundsRect.y);
			} else {
				thumb.x = Math.max(_thumbBoundsRect.x, Math.min(_thumbBoundsRect.x + _thumbBoundsRect.width - thumb.width, mouseX - _thumbOffset.x));
				thumb.y = _thumbBoundsRect.y;
				p = (thumb.x - _thumbBoundsRect.x) / ((_thumbBoundsRect.width - thumb.width) - _thumbBoundsRect.x);
			}
			if (tweenThumbMotion) {
				percent = p;
			} else {
				percent = getClosestScrollLinePercent(p);
			}
		}
		
		
		
		protected function setPercentTween(endPercent:Number, fireCompleteEvent:Boolean = false, ease:Function = null, duration:Number = 0):void {
			killPercentTween();
			if (!enabled) return;
			if (tweenThumbMotion) {
				if (duration == 0) {
					duration = Math.max(minScrollDuration, maxScrollDuration * Math.abs(endPercent - percent));
				}
				if (ease == null) {
					ease = Linear.easeInOut;
				}
				_percentTween = TweenLite.to(this, duration, { percent:endPercent, onComplete:(fireCompleteEvent ? onPercentTweenFinish : null) });
				/*new Tween(this, "percent", ease, percent, endPercent, duration, true);
				if (fireCompleteEvent) {
					_percentTween.addEventListener(TweenEvent.MOTION_FINISH, onPercentTweenFinish);
				}*/
			} else {
				_percentTarget = endPercent;
				addEventListener(Event.ENTER_FRAME, onEnterFrameStepHandler);
			}
		}
		
		protected function killPercentTween():void {
			if (_percentTween) {
				//_percentTween.stop();
				//_percentTween.removeEventListener(TweenEvent.MOTION_FINISH, onPercentTweenFinish);
				TweenLite.killTweensOf(this);
				_percentTween = null;
			}
			removeEventListener(Event.ENTER_FRAME, onEnterFrameEaseHandler);
			removeEventListener(Event.ENTER_FRAME, onEnterFrameStepHandler);
		}
		
		
		
		protected function onPercentTweenFinish():void {//evt:TweenEvent):void {
			killPercentTween();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		protected function easeToStop():void {
			killPercentTween();
			if (!enabled) return;
			if (tweenThumbMotion) {
				_stopEasePercent = _percent - _prevPercent;
				if (_stopEasePercent != 0) {
					addEventListener(Event.ENTER_FRAME, onEnterFrameEaseHandler);
				}
			}
		}
		
		/**
		 * After a tween (set via setPercentTween()) is interrupeded (such as when buttonDown is released),
		 * the change in percent is decelerated via easeToStop(), which sets a listener for Event.ENTER_FRAME
		 * which in turn calls this method.
		 */
		protected function onEnterFrameEaseHandler(evt:Event):void {
			if (Math.abs(_stopEasePercent) < 0.01) {
				_stopEasePercent = 0;
				setPercentTween(getClosestScrollLinePercent(percent), true);
			} else {
				_stopEasePercent *= 0.9;
				percent += _stopEasePercent;
			}
		}
		
		
		protected function onEnterFrameStepHandler(evt:Event):void {
			var p:Number = percent + ((_percentTarget > percent) ? _scrollLinePercent : -_scrollLinePercent);
			if ((percent < _percentTarget && p >= _percentTarget) || (percent > _percentTarget && p <= _percentTarget)) {
				percent = _percentTarget;
				removeEventListener(Event.ENTER_FRAME, onEnterFrameStepHandler);
				dispatchEvent(new Event(Event.COMPLETE));
			} else {
				percent = p;
			}
		}


		/**
		 * The total time, in seconds, it takes to scroll from 0 to 1 (or vice versa) if buttonDown is held down.
		 * 
		 * @see com.disbranded.ui.DScroll#minScrollDuration
		 * 
		 * @default 1.0
		 */
		public function get maxScrollDuration():Number {
			return _maxScrollDuration;
		}
		
		public function set maxScrollDuration(secs:Number):void {
			_maxScrollDuration = secs;
		}


		/**
		 * The minimum scroll duration.
		 * 
		 * @see com.disbranded.ui.DScroll#minScrollDuration
		 * 
		 * @default 1.0
		 */
		public function get minScrollDuration():Number {
			return _minScrollDuration;
		}
		
		public function set minScrollDuration(secs:Number):void {
			_minScrollDuration = secs;
		}



		/**
		 * Determines whether the percent (and therefore the thumb) should animate
		 * on an easing tween.
		 * 
		 * @default true
		 */
		public function get tweenThumbMotion():Boolean {
			return _tweenThumbMotion;
		}
		
		public function set tweenThumbMotion(b:Boolean):void {
			_tweenThumbMotion = b;
		}


		
		
		public function get percent():Number {
			return _percent;
		}
		
		public function set percent(n:Number):void {
			_prevPercent = _percent;
			_percent = Math.max(0, Math.min(1, n));
			positionThumb();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		
		
		protected function positionThumb():void {
			if (thumb == null || _thumbDragging) return;
			if (direction == "vertical") {
				thumb.y = thumbBoundsRect.y + (thumbBoundsRect.height - thumb.height) * _percent;
				if (roundThumbPosition) {
					thumb.y = Math.max(thumbBoundsRect.y, Math.min(thumbBoundsRect.y + thumbBoundsRect.height, Math.round(thumb.y)));
				}
			} else {
				thumb.x = thumbBoundsRect.x + (thumbBoundsRect.width - thumb.width) * _percent;
				if (roundThumbPosition) {
					thumb.x = Math.max(thumbBoundsRect.x, Math.min(thumbBoundsRect.x + thumbBoundsRect.width, Math.round(thumb.x)));
				}
			}
		}
		
		
		
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enabled(b:Boolean):void {
			if (b && !(_scrollPagePercent < 1 && _scrollPagePercent > 0)) {
				b = false;
			}
			if (_enabled == b) return;
			_enabled = b;
			mouseEnabled = mouseChildren = _enabled;
			/*if (track) {
				track.mouseEnabled = _enabled && scrollPagePercent < 1 && scrollPagePercent > 0;
			}
			if (thumb) {
				thumb.mouseEnabled = _enabled && scrollPagePercent < 1 && scrollPagePercent > 0;
			}
			setButtonsEnabled();*/
			setKeyboardEnabled(_enabled);
			visible = _enabled;
		}
		
		protected function setButtonsEnabled():void {
			if (buttonUp) {
				buttonUp.mouseEnabled = _enabled && percent > 0 && scrollPagePercent < 1;
			}
			if (buttonDown) {
				buttonDown.mouseEnabled = _enabled && percent < 1 && scrollPagePercent < 1;
			}
		}
		
		
		
		/**
		 * @default true
		 */
		public function get keyboardEnabled():Boolean {
			return _keyboardEnabled;
		}
		
		public function set keyboardEnabled(b:Boolean):void {
			if (_keyboardEnabled == b) return;
			_keyboardEnabled = b;
			setKeyboardEnabled(_keyboardEnabled);
		}
		
		
		protected function setKeyboardEnabled(val:Boolean):void {
			if (stage == null) return;
			if (enabled && val) {
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
			} else {
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
			}
		}
		
		
		protected function onKeyboardDown(evt:KeyboardEvent):void {
			if (!enabled) return;
			if (direction == "vertical") {
				if ((evt.keyCode == Keyboard.SPACE && !evt.shiftKey) || evt.keyCode == Keyboard.PAGE_DOWN) {
					setPercentTween(getClosestScrollLinePercent(percent + scrollPagePercent), true);
				} else if ((evt.keyCode == Keyboard.SPACE && evt.shiftKey) || evt.keyCode == Keyboard.PAGE_UP) {
					setPercentTween(getClosestScrollLinePercent(percent - scrollPagePercent), true);
				} else if (evt.keyCode == Keyboard.DOWN) {
					setPercentTween(getClosestScrollLinePercent(percent + scrollLinePercent), true);
				} else if (evt.keyCode == Keyboard.UP) {
					setPercentTween(getClosestScrollLinePercent(percent - scrollLinePercent), true);
				} else if (evt.keyCode == Keyboard.HOME) {
					setPercentTween(0, true);
				} else if (evt.keyCode == Keyboard.END) {
					setPercentTween(1, true);
				}
			} else if (direction == "horizontal") {
				if (evt.keyCode == Keyboard.RIGHT) {
					setPercentTween(getClosestScrollLinePercent(percent + scrollLinePercent), true);
				} else if (evt.keyCode == Keyboard.LEFT) {
					setPercentTween(getClosestScrollLinePercent(percent - scrollLinePercent), true);
				}
			}
		}
		
		
		
		protected function onAddedToStage(evt:Event = null):void {
			//MacMouseWheel.setup(stage);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			setKeyboardEnabled(_keyboardEnabled);
		}
		
		protected function onRemovedFromStage(evt:Event = null):void {
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			setKeyboardEnabled(false);
		}
		
		
		
		
		/**
		 * Percent of each line or item in whatever is to be scrolled. For example, if scrolling a block of content
		 * that is composed of 10 items that are each 100 pixels tall, scrollLinePercent should be set to 0.1 (100 pixels per item / 1000 total pixels == 0.1).
		 * When a scrolling action is complete, the scroller will settle to the closest scrollLinePercent.
		 * 
		 * <p>Ignored if set to 0.</p>
		 * 
		 * @default 0.05
		 */
		public function get scrollLinePercent():Number {
			return _scrollLinePercent;
		}
		
		public function set scrollLinePercent(n:Number):void {
			_scrollLinePercent = n;
		}

		
		
		/**
		 * Percent of each line or item in whatever is to be scrolled. For example, if scrolling a block of content
		 * that is composed of 10 items that are each 100 pixels tall, scrollLinePercent should be set to 0.1 (100 pixels per item / 1000 total pixels == 0.1).
		 * When a scrolling action is complete, the scroller will settle to the closest scrollLinePercent.
		 * 
		 * <p>Ignored if set to 0.</p>
		 * 
		 * @default 0.25
		 */
		public function get scrollPagePercent():Number {
			return _scrollPagePercent;
		}
		
		public function set scrollPagePercent(n:Number):void {
			_scrollPagePercent = n;
			enabled = _scrollPagePercent < 1 && _scrollPagePercent > 0;
			setThumbProportion();
		}
		
		
		protected function getClosestScrollLinePercent(p:Number):Number {
			return getClosestPercent(p, scrollLinePercent);
		}		
		
		protected function getClosestScrollPagePercent(p:Number):Number {
			return getClosestPercent(p, scrollPagePercent);
		}
		
		protected function getClosestPercent(p:Number, s:Number):Number {
			if (s == 0) {
				return p;
			}
			var n:Number = 1;
			var c:Number = 1;
			var t:Number = 0;
			while (t <= 1) {
				var d:Number = Math.abs(t - p);
				if (d < c) {
					c = d;
					n = t;
				}
				if (t < 1) {
					t += s;
					t = Math.min(1, t);
				} else {
					break;
				}
			}
			return n;
		}
		
		
		
		/**
		 * If true, rounds the thumb y.
		 * 
		 * @default false
		 */
		public function get roundThumbPosition():Boolean {
			return _roundThumbPosition;
		}
		
		public function set roundThumbPosition(b:Boolean):void {
			_roundThumbPosition = b;
			positionThumb();
		}



		/**
		 * Works just like fl.controls.ScrollBar.direction.
		 * 
		 * @see fl.controls.ScrollBar;
		 * @see fl.controls.ScrollBarDirection;
		 * 
		 * @default vertical
		 */
		public function get direction():String {
			return _direction;
		}

		public function set direction(val:String):void {
			if (val != _direction && val == "horizontal" || val == "vertical") {
				_direction = val;
			}
			positionThumb();
			setThumbProportion();
		}
		
		
		
		/**
		 * Get and set the layout style for up and down buttons. If mcTrack or mcThumb exist, then during init()
		 * layout is determined automatically by whether mcBtnUp.y == 0. This is rather crude, so setting layoutStyle
		 * here will override that automatic setting.
		 * 
		 * <p>Possible values include: DScrollerLayout.LAYOUT_NORMAL (buttonUp is flush top, track in the middle, buttonDown is flush bottom),
		 * and DScrollerLayout.LAYOUT_MAC (track is flush top, with buttonUp and buttonDown at bottom).</p>
		 * 
		 * <p>An attempt to automatically set layoutStyle occurs each time buttonUp or buttonDown is set, so any
		 * custom layoutStyle will need to be reset if the value of buttonUp or buttonDown is changed.</p>
		 * 
		 * @default DScrollerLayout.LAYOUT_NORMAL
		 */
		public function get layoutStyle():String {
			return _layoutStyle;
		}
		
		public function set layoutStyle(val:String):void {
			_layoutStyle = val;
			setSize(super.width, super.height);
		}
		
		
		/**
		 * Lays out display objects according to layoutStyle.
		 * 
		 * @see com.disbranded.ui.DScroller#layoutStyle
		 */
		override public function get height():Number {
			return _height;
		}
		
		override public function set height(n:Number):void {
			_height = n;
			if (_direction == "vertical") {
				if (_layoutStyle == DScrollerLayout.LAYOUT_NORMAL) {
					if (buttonUp) {
						buttonUp.y = 0;
					}
					if (track) {
						track.y = buttonUp ? (buttonUp.y + buttonUp.height) : 0;
					}
					if (buttonDown) {
						buttonDown.y = track ? (track.y + track.height) : (buttonUp.y + buttonUp.height);
					}
				} else if (_layoutStyle == DScrollerLayout.LAYOUT_MAC) {
					if (track) {
						track.y = 0;
						buttonUp.y = track.y + track.height;
					} else {
						buttonUp.y = 0;
					}
					if (buttonDown) {
						buttonDown.y = buttonUp ? (buttonUp.y + buttonUp.height) : 0;
					}
				}
				positionThumb();
			} else {
				super.height = _height;
			}
		}
		
		
		/**
		 *
		 */
		override public function get width():Number {
			return _width;
		}
		
		override public function set width(n:Number):void {
			_width = n;
			if (_direction == "horizontal") {
				if (_layoutStyle == DScrollerLayout.LAYOUT_NORMAL) {
					if (buttonUp) {
						buttonUp.x = 0;
					}
					if (track) {
						track.x = buttonUp ? (buttonUp.y + buttonUp.width) : 0;
					}
					if (buttonDown) {
						buttonDown.x = track ? (track.x + track.width) : (buttonUp.x + buttonUp.width);
					}
				} else if (_layoutStyle == DScrollerLayout.LAYOUT_MAC) {
					if (track) {
						track.x = 0;
						buttonUp.x = track.x + track.width;
					} else {
						buttonUp.x = 0;
					}
					if (buttonDown) {
						buttonDown.x = buttonUp ? (buttonUp.x + buttonUp.width) : 0;
					}
				}
				positionThumb();
			} else {
				super.width = _width;
			}
		}
		
		
		
		public function setSize(w:Number, h:Number):void {
			width = w;
			height = h;
		}
		
		
		
		
		/**
		 * The track sets the boundary for the thumb and is also
		 * a button in its own right.
		 * 
		 * <p>If no track is set, thumbBoundsRect must be set instead.</p>
		 * 
		 * <p>To set on the timeline in the Flash IDE, give the movieclip an instance name of mcTrack.<p>
		 */
		public function get track():InteractiveObject {
			return _track;
		}
		
		public function set track(obj:InteractiveObject):void {
			deactivateTrack();
			_track = obj;
			if (_track) {
				thumbBoundsRect = new Rectangle(_track.x, _track.y, _track.width, _track.height);
			}
			activateTrack();
		}

		
		
		/**
		 * To set on the timeline in the Flash IDE, give the movieclip an instance name of mcThumb.
		 */
		public function get thumb():InteractiveObject {
			return _thumb;
		}
		
		public function set thumb(obj:InteractiveObject):void {
			deactivateThumb();
			_thumb = obj;
			activateThumb();
		}
		
		
		/**
		 * @default true
		 */
		public function get thumbIsProportional():Boolean {
			return _thumbIsProportional;
		}
		
		public function set thumbIsProportional(val:Boolean):void {
			_thumbIsProportional = val;
			setThumbProportion();
		}
		
		
		protected function setThumbProportion():void {
			if (thumb == null) return;
			if (thumbIsProportional) {
				if (direction == "vertical") {
					thumb.scaleX = 1;
					thumb.height = scrollPagePercent * thumbBoundsRect.height;
					if (roundThumbPosition) {
						thumb.height = Math.round(thumb.height);
					}
				} else {
					thumb.scaleY = 1;
					thumb.width = scrollPagePercent * thumbBoundsRect.width;
					if (roundThumbPosition) {
						thumb.width = Math.round(thumb.width);
					}
				}
			} else {
				thumb.scaleX = thumb.scaleY = 1;
			}
			positionThumb();
		}
		
		
		/**
		 * To set on the timeline in the Flash IDE, give the movieclip an instance name of mcBtnUp.
		 */
		public function get buttonUp():InteractiveObject {
			return _btnUp;
		}
		
		public function set buttonUp(obj:InteractiveObject):void {
			deactivateButtonUp();
			_btnUp = obj;
			activateButtonUp();
			determineLayoutStyle();
			setButtonsEnabled();
		}
		
		/**
		 * To set on the timeline in the Flash IDE, give the movieclip an instance name of mcBtnDown.
		 */
		public function get buttonDown():InteractiveObject {
			return _btnDown;
		}
		
		public function set buttonDown(obj:InteractiveObject):void {
			deactivateButtonDown();
			_btnDown = obj;
			activateButtonDown();
			determineLayoutStyle();
			setButtonsEnabled();
		}
		
		
		/**
		 * Is the DScroller instance has a thumb, then either track or thumbBoundsRect must be set
		 * in order to set the dragging or scrolling boundary of the thumb.
		 */
		public function get thumbBoundsRect():Rectangle {
			return _thumbBoundsRect;
		}
		
		public function set thumbBoundsRect(rect:Rectangle):void {
			_thumbBoundsRect = rect;
		}
		

	}
}
