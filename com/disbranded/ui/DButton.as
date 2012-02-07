

package com.disbranded.ui {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.ui.Keyboard;
	import flash.utils.Timer;


	/**
	 * Dispatched if <code>autoRepeat</code> is true at specified intervals until the button is released.
	 * 
	 * <p>Constant to use: DButton.BUTTON_DOWN</p>
	 * 
	 * @see fl.events.ComponentEvent#buttonDown
	 */
	[Event("buttonDown", type="flash.events.Event")]
	

	public class DButton extends Sprite {
		
		public var id:String;
		
		protected var _mouseState:String;
		protected var _oldMouseState:String;
		
		protected var _draggable:Boolean = false;
		protected var _emphasized:Boolean = false;
		protected var _enabled:Boolean = true;
		protected var _focused:Boolean = false;
		
		protected var _dragging:Boolean = false;
		protected var _mouseIsOver:Boolean = false;
		
		//added 9/14/10
		protected var _retainFocusOnMouseOut:Boolean = false;
		
		protected var _selected:Boolean = false;
		protected var _toggle:Boolean = false;

		protected var _autoRepeat:Boolean = false;
		protected var _repeatDelay:Number = 500;
		protected var _repeatInterval:Number = 35;
		protected var _pressTimer:Timer;
		protected var _repeatFrames:Boolean = false;

		/**
		 * If set, plays on MOUSE_OVER.
		 */
		public var soundOver:Sound;
		
		/**
		 * If set, plays on MOUSE_OUT.
		 */
		public var soundOut:Sound;
		
		/**
		 * If set, plays on MOUSE_DOWN.
		 */
		public var soundDown:Sound;
		
		/**
		 * If set, plays on CLICK.
		 */
		public var soundClick:Sound;
		
		/**
		 * If set, plays on DOUBLE_CLICK.
		 */
		public var soundDoubleClick:Sound;
		
		
		public static const BUTTON_DOWN:String = "buttonDown";



		/**
		 * DButton is designed to have virtually the same API as fl.controls.Button, but
		 * without incorporating styles or labels any other visual artifacts.
		 * 
		 * <p>It is designed to be extended by a Sprite that <i>does</i> have graphics.</p>
		 * 
		 * <p>Any time a property changes, such as the mouse state, draw() will be called. Override this method to update the visual state of the DButton.</p>
		 * 
		 * @see fl.controls.Button
		 * @see #draw()
		 */
		public function DButton() {
			super();
			init();
		}
		
		
		protected function init():void {
			mouseChildren = tabChildren = false;
			buttonMode = true;
			focusRect = false;
			activate();
			tabEnabled = true;
			invalidate();
		}
		

		/**
		 * This method is designed to be overridden. It's basically what DButton is for.
		 * 
		 * <p>Test for the values of _mouseState, _emphasized, _enabled, _focused, _selected</p>
		 * 
		 * @see #emphasized
		 * @see #enabled
		 * @see #focused
		 * @see #selected
		 */
		protected function draw():void {
			//trace("mouseState:"+_mouseState +" emphasized:"+_emphasized +" enabled:"+_enabled +" focused:"+_focused);
		}
		
		
		/**
		 * Reactivates events. Only needs to be called to reverse deactivate().
		 */
		public function activate():void {
			addMouseEvents();
			if (tabEnabled) {
				addTabEvents();
			}
		}
		
		/**
		 * Deactivates all events.
		 */
		public function deactivate():void {
			removeMouseEvents();
			if (tabEnabled) {
				removeTabEvents();
			}			
		}
		
		
		
		/**
		 * Allows use of mouseOver and mouseOut behavior for focus events. For example, when
		 * retainFocusOnMouseOut==FALSE, if a button is focused via CLICK, then it will lose
		 * focus on MOUSE_OUT. Otherwise, retainFocusOnMouseOut is essentially Flash's default
		 * behavior, so if a button used the same animation for both FOCUS_IN and MOUSE_OVER then
		 * after CLICK it would retain the MOUSE_OVER animation state even after MOUSE_OUT event.
		 * 
		 * @default false
		 */
		public function get retainFocusOnMouseOut():Boolean {
			return _retainFocusOnMouseOut;
		}
		
		public function set retainFocusOnMouseOut(b:Boolean):void {
			_retainFocusOnMouseOut = b;
		}
		
		
		
		
		/**
		 * @default true
		 */
		public function get enabled():Boolean { 
			return _enabled;
		}
		/**
		 * @private
		 */		
		public function set enabled(value:Boolean):void {
			if (_enabled == value) return;
			_enabled = value;
			mouseEnabled = tabEnabled = _enabled;
			_focused = false;
			invalidate();
		}
		
		
		/**
		 * @default true
		 */
		override public function get tabEnabled():Boolean {
			return super.tabEnabled;
		}
		/**
		 * @private
		 */
		override public function set tabEnabled(value:Boolean):void {
			if (super.tabEnabled == value) return;
			super.tabEnabled = value;
			updateTabEnabled();
		}
		
		
		
		/**
		 * @default false
		 * 
		 * @see fl.controls.Button.#emphasized
		 */
		public function get emphasized():Boolean { 
			return _emphasized;
		}
		/**
		 * @private
		 */	
		public function set emphasized(value:Boolean):void {
			if (_emphasized == value) return;
			_emphasized = value;
			invalidate();
		}
		
		
		/**
		 * Works in conjunction with toggle.
		 * 
		 * @default false
		 * 
		 * @see #toggle
		 * @see fl.controls.Button.#selected
		 */
		public function get selected():Boolean {
			return (_toggle) ? _selected : false;
		}
		/**
		 * @private
		 */
		public function set selected(value:Boolean):void {
			if (_selected == value) return;
			_selected = value;
			if (_toggle) {
				invalidate();
			}
		}
		
		
		
		/**
		 * For checkbox and radio controls.
		 * 
		 * @default false
		 * 
		 * @see #selected
		 * @see fl.controls.Button.#toggle
		 */
		public function get toggle():Boolean {
			return _toggle;
		}
		/**
		 * @private
		 */
		public function set toggle(value:Boolean):void {
			if (!value && _selected) {
				selected = false;
			}
			_toggle = value;
			if (_toggle) {
				addEventListener(MouseEvent.CLICK, toggleSelected, false, 0, true);
			} else {
				removeEventListener(MouseEvent.CLICK, toggleSelected);
			}
			invalidate();
		}		
		
		protected function toggleSelected(event:MouseEvent):void {
			selected = !selected;
			dispatchEvent(new Event(Event.CHANGE, true));
		}
		
		
		
		
		
		/**
		 * The button needs to behave differently towards different mouse states when then button can be dragged.
		 * 
		 * <p>When draggable, the button listens to the Stage for MOUSE_UP and MOUSE_LEAVE and fires MouseEvent.MOUSE_UP when dragging should stop.</p>
		 * 
		 * @default false
		 */
		public function get draggable():Boolean {
			return _draggable;
		}
		/**
		 * @private
		 */
		public function set draggable(b:Boolean):void {
			if (_draggable == b) return;
			_draggable = b;			
			invalidate();
		}
		
		
		
		/**
		 * @param state String, must be "up", "down", or "over"
		 */
		public function setMouseState(state:String):void {
			if (_mouseState == state) return;
			if (state == "up" || state == "down" || state == "over") {
				_mouseState = state;
				invalidate();
			}
		}
		
		
		
		override public function get hitArea():Sprite {
			return super.hitArea;
		}
		/**
		 * @inheritDoc
		 */
		override public function set hitArea(spr:Sprite):void {
			super.hitArea = spr;
			super.hitArea.buttonMode = buttonMode;
			spr.mouseEnabled = spr.mouseChildren = false;
		}
		
		
		
		/**
		 * @see fl.controls.BaseButton#autoRepeat
		 */
		public function get autoRepeat():Boolean {
			return _autoRepeat;
		}
		/**
		 * @private
		 */
		public function set autoRepeat(b:Boolean):void {
			if (_autoRepeat == b) return;
			_autoRepeat = b;
			if (_autoRepeat) {
				if (_pressTimer == null) {
					_pressTimer = new Timer(1, 0);
				}				
				_pressTimer.addEventListener(TimerEvent.TIMER, pressRepeat, false, 0, true);
			} else {
				_pressTimer.removeEventListener(TimerEvent.TIMER, pressRepeat);
			}
		}

		/**
		 * Time in milliseconds before "buttonDown" event starts repeatedly firing.
		 * 
		 * For use with <code>autoRepeat</code>.
		 * 
		 * @see #autoRepeat
		 */
		public function get repeatDelay():Number {
			return _repeatDelay;
		}
		/**
		 * @private
		 */
		public function set repeatDelay(n:Number):void {
			if (_repeatDelay == n) return;
			_repeatDelay = n;
		}

		/**
		 * Time in milliseconds between dispatches of "buttonDown" event.
		 * 
		 * For use with <code>autoRepeat</code>.
		 * 
		 * @see #autoRepeat
		 */
		public function get repeatInterval():Number {
			return _repeatInterval;
		}
		/**
		 * @private
		 */
		public function set repeatInterval(n:Number):void {
			if (_repeatInterval == n) return;
			_repeatInterval = n;
		}

		/**
		 * Use Event.ENTER_FRAME instead of a Timer delay to dispatch "buttonDown" events.
		 * 
		 * For use with <code>autoRepeat</code>.
		 * 
		 * @see #autoRepeat
		 * @see #repeatInterval
		 */
		public function get useFramesForRepeat():Boolean {
			return _repeatFrames;
		}
		/**
		 * @private
		 */
		public function set useFramesForRepeat(b:Boolean):void {
			if (_repeatFrames == b) return;
			_repeatFrames = b;
		}
		
		
		
		
		
		
		/*
		* Mouse events
		*/
		protected function addMouseEvents():void {
			addEventListener(MouseEvent.CLICK, mouseEventClick, false, 0, true);
			addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler, false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler, false, 0, true);
			addEventListener(MouseEvent.DOUBLE_CLICK, mouseEventHandler, false, 0, true);
		}
		
		protected function removeMouseEvents():void {
			removeEventListener(MouseEvent.CLICK, mouseEventClick);
			removeEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
			removeEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
			removeEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
			removeEventListener(MouseEvent.DOUBLE_CLICK, mouseEventHandler);
		}
		
		protected function mouseEventHandler(evt:MouseEvent):void {
			if (tabEnabled && !_retainFocusOnMouseOut && stage) {
				if (stage.focus == this && evt.type == MouseEvent.ROLL_OUT) {
					stage.focus = null;
					_focused = false;
					invalidate();
				}
			}
			switch (evt.type) {
				case MouseEvent.MOUSE_DOWN:
					if (_draggable) {
						_dragging = true;
					}
					startPressTimer();
					if (soundDown) {
						soundDown.play(0);
					}
					setMouseState("down");
					break;
				case MouseEvent.ROLL_OVER:
					_mouseIsOver = true;
					if (soundOver) {
						soundOver.play(0);
					}
					setMouseState("over");
					break;
				case MouseEvent.MOUSE_UP:
					if (_dragging) {
						_dragging = false;
						if (stage) {
							stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
							stage.removeEventListener(Event.MOUSE_LEAVE, stopDragging);
						}
					}
					endPressTimer();
					setMouseState("up");
					break;
				case MouseEvent.ROLL_OUT:
					_mouseIsOver = false;
					if (_dragging && evt.buttonDown) {
						if (stage) {
							stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
							stage.addEventListener(Event.MOUSE_LEAVE, stopDragging);
						}
					} else {
						endPressTimer();
						if (soundOut) {
							soundOut.play(0);
						}
						setMouseState("up");
					}
					break;
				case MouseEvent.DOUBLE_CLICK:
					if (soundDoubleClick) {
						soundDoubleClick.play(0);
					}
				default:
					break;
			}
		}
		
		protected function stopDragging(evt:Event):void {
			dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		}
		
		protected function mouseEventClick(evt:MouseEvent):void {
			if (soundClick) {
				soundClick.play(0);
			}
		}
		
		
		/*
		* Focus, tab, and keyboard
		*/
		protected function updateTabEnabled():void {
			if (tabEnabled) {
				addTabEvents();
			} else {
				removeTabEvents();
			}
		}
		
		protected function addTabEvents():void {
			addEventListener(FocusEvent.FOCUS_IN, focusInHandler, false, 0, true);
			addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler, false, 0, true);
			addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, 0, true);
			addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, 0, true);
		}
		
		protected function removeTabEvents():void {
			removeEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			removeEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
			removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}

		protected function focusInHandler(evt:FocusEvent):void {
			_focused = true;
			invalidate();
		}
		
		protected function focusOutHandler(evt:FocusEvent):void {
			_focused = false;
			invalidate();
		}
		
		protected function keyDownHandler(evt:KeyboardEvent):void {
			if (!enabled) { return; }
			if (evt.keyCode == Keyboard.SPACE || evt.keyCode == Keyboard.ENTER) {
				if(_oldMouseState == null) {
					_oldMouseState = _mouseState;
				}
				startPressTimer();
				setMouseState("down");
			}
		}
		
		protected function keyUpHandler(evt:KeyboardEvent):void {
			if (!enabled) { return; }
			if (evt.keyCode == Keyboard.SPACE || evt.keyCode == Keyboard.ENTER) {
				endPressTimer();
				setMouseState(_oldMouseState);
				_oldMouseState = null;
				dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
		}
		
		
		
		/*
		* Press down REPEAT
		*/
		protected function startPressTimer():void {
			if (_autoRepeat) {
				_pressTimer.delay = _repeatDelay;
				_pressTimer.start();
			}
			dispatchEvent(new Event(DButton.BUTTON_DOWN, true));
			
		}

		protected function pressRepeat(evt:TimerEvent):void {
			if (!_autoRepeat) {
				endPressTimer();
			} else {
				if (_repeatFrames) {
					_pressTimer.reset();
					addEventListener(Event.ENTER_FRAME, pressRepeatFrames);
				} else if (_pressTimer.currentCount == 1) {
					_pressTimer.delay = _repeatInterval;
				}
				dispatchEvent(new Event(DButton.BUTTON_DOWN, true));
			}
		}
		
		protected function pressRepeatFrames(evt:Event):void {
			if (!_autoRepeat) {
				removeEventListener(Event.ENTER_FRAME, pressRepeatFrames);
			} else {
				dispatchEvent(new Event(DButton.BUTTON_DOWN, true));
			}
		}
		
		protected function endPressTimer():void {
			if (_pressTimer) {
				_pressTimer.reset();	
			}			
			if (_repeatFrames) {
				removeEventListener(Event.ENTER_FRAME, pressRepeatFrames);
			}
		}

		
		
		/*
		* Stage RENDER
		*/
		protected function invalidate():void {
			if (stage) {
				callDraw();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, addedToStageForDraw, false, 0, true);
			}
		}
		
		protected function callDraw():void {
			stage.addEventListener(Event.RENDER, render, false, 0, true);
			stage.invalidate();
		}
		
		protected function addedToStageForDraw(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageForDraw);
			callDraw();
		}
		
		protected function render(evt:Event):void {
			if (stage) {
				stage.removeEventListener(Event.RENDER, render);
				draw();
			}
		}
	}
}
