///////////////////////////////////////////////////////////////////////
// com.disbranded.ui.ScalingButtonGroup
///////////////////////////////////////////////////////////////////////

package com.disbranded.ui {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;


	/**
	 *	@author Adrian Lafond / Disbranded, Inc.
	 *	@date 2010-10-05
	 */
	public class ScalingButtonGroup extends EventDispatcher {
		
		
		protected var _btns:Array;
		protected var _btnRects:Array;
		protected var _margins:Array;
		protected var _marginPx:Number;
		
		protected var _emphasizedIndex:int = -1;
		protected var _userFocused:Boolean;

		protected var _pos:Number;
		protected var _size:Number;
		
		protected var _focusScale:Number = 2.0;
		protected var _easeScale:Number = 0.75;
		protected var _minScale:Number = 0.5;
		
		
		protected var _tweenSecs:Number = 0.5;
		protected var _ease:Function = Regular.easeOut;
		protected var _tweens:Array;
		
		protected var _roundCoords:Boolean = true;
		protected var _direction:String  = "vertical";
		
		
		

		public function ScalingButtonGroup() {
			super();
		}
	
	
		public function addButtons(btns:Array):void {
			removeButtons();
			_btns = btns;
			if (_btnRects == null) {
				_btnRects = new Array();
			}
			if (_margins == null) {
				_margins = new Array();
			}
			var len:int = _btns.length;
			for (var i:int = 0; i < len; i++) {
				_btns[i].addEventListener(MouseEvent.ROLL_OVER, onBtnFocus, false, 0, true);
				_btns[i].addEventListener(FocusEvent.FOCUS_IN, onBtnFocus, false, 0, true);
				_btns[i].addEventListener(MouseEvent.ROLL_OUT, onBtnBlur, false, 0, true);	
				_btns[i].addEventListener(FocusEvent.FOCUS_OUT, onBtnBlur, false, 0, true);
				_btnRects[i] = new Rectangle(_btns[i].x, _btns[i].y, _btns[i].width, _btns[i].height);
			}
			
			_marginPx = 0;
			var propPos:String = (direction == "vertical") ? "y" : "x";
			var propSize:String = (direction == "vertical") ? "height" : "width";
			for (i = 0; i < len; i++) {
				if (i == len - 1) {
					_margins[i] = 0;
				} else {
					_margins[i] = _btnRects[i + 1][propPos] - (_btnRects[i][propPos] + _btnRects[i][propSize]);
				}
				_marginPx += _margins[i];
			}
			_pos = _btnRects[0][propPos];
			_size = _btnRects[len - 1][propPos] + _btnRects[len - 1][propSize] - _btnRects[0][propPos] - _marginPx;
			
			scaleButtons(emphasizedIndex);
		}
		
		
		
		public function removeButtons():void {
			if (_btns == null) return;
			var len:int = _btns.length;
			for (var i:int = 0; i < len; i++) {
				_btns[i].removeEventListener(MouseEvent.ROLL_OVER, onBtnFocus);
				_btns[i].removeEventListener(FocusEvent.FOCUS_IN, onBtnFocus);
				_btns[i].removeEventListener(MouseEvent.ROLL_OUT, onBtnBlur);
				_btns[i].removeEventListener(FocusEvent.FOCUS_OUT, onBtnBlur);
			}
			_btns.splice(0, len);
			_btnRects.splice(0, len);
			_margins.splice(0, len);
			_emphasizedIndex = -1;
		}



		/**
		 * Rounds button y and height (or x and width if direction is "horizontal")
		 * so that edges are crisp.
		 * 
		 * @default true
		 */
		public function get roundCoords():Boolean {
			return _roundCoords;
		}
		
		public function set roundCoords(b:Boolean):void {
			_roundCoords = b;
		}



		/**
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
		}


		/**
		 * The target scale of the emphasized/focused button.
		 * 
		 * @default 2.0;
		 */
		public function get focusScale():Number {
			return _focusScale;
		}

		public function set focusScale(n:Number):void {
			_focusScale = n;
		}

		/**
		 * Starting with the focusScale, the amount by which the scale is dropped on each iteration through the buttons loop.
		 * 
		 * @default 0.75;
		 */
		public function get easeScale():Number {
			return _easeScale;
		}

		public function set easeScale(n:Number):void {
			_easeScale = n;
		}
		
		
		/**
		 * The smallest scale that a button is allowed to shrink to.
		 * 
		 * @default 0.5;
		 */
		public function get minScale():Number {
			return _minScale;
		}

		public function set minScale(n:Number):void {
			_minScale = n;
		}



		/**
		 * @default -1
		 */
		public function get emphasizedIndex():int {
			return _emphasizedIndex;
		}
		
		public function set emphasizedIndex(n:int):void {
			_emphasizedIndex = n;
			if (!_userFocused) {
				scaleButtons(_emphasizedIndex);
			}
		}
		
		
		
		public function get y():Number {
			return (direction == "vertical") ? _pos : 0;
		}		
		
		public function get height():Number {
			return (direction == "vertical") ? (_size + _marginPx) : 0;
		}
		
		public function get x():Number {
			return (direction == "horizontal") ? _pos : 0;
		}		
		
		public function get width():Number {
			return (direction == "horizontal") ? (_size + _marginPx) : 0;
		}

		public function get pos():Number {
			return _pos
		}		
		
		public function get size():Number {
			return _size;
		}


		/**
		 * Set to 0 to turn off tweening.
		 * 
		 * @default 0.5
		 */
		public function get tweenSecs():Number {
			return _tweenSecs;
		}

		public function set tweenSecs(secs:Number):void {
			_tweenSecs = Math.max(0, secs);
		}
		
		
		
		/**
		 * @default fl.transitions.easing.Regular.easeOut
		 */
		public function get ease():Function {
			return _ease;
		}
		
		public function set ease(fn:Function):void {
			_ease = fn;
		}



		protected function onBtnFocus(evt:Event):void {
			_userFocused = true;
			scaleButtons(getBtnIndex(evt.target));
		}
		
		protected function onBtnBlur(evt:Event):void {
			_userFocused = false;
			scaleButtons(emphasizedIndex);
		}
		
		
		
		
		protected function scaleButtons(focusIndex:int = -1):void {
			if (_btns == null) return;
			var len:int = _btns.length;
			var targetPos:Array = new Array(len);
			var targetSize:Array = new Array(len);
			var totalPx:int = 0;
			var i:int;
			
			if (focusIndex == -1) {
				for (i = 0; i < len; i++) {
					targetSize[i] = getBtnSize(i);
				}
				
			} else {
				targetSize[focusIndex] = getBtnSize(i) * _focusScale;
				var fs:Number = _focusScale;
				for (i = focusIndex - 1; i >= 0; i--) {
					fs *= _easeScale;
					targetSize[i] = getBtnSize(i) * Math.max(_minScale, fs);
				}
				fs = _focusScale;
				for (i = focusIndex + 1; i < len; i++) {
					fs *= _easeScale;
					targetSize[i] = getBtnSize(i) * Math.max(_minScale, fs);
				}

				for (i = 0; i < len; i++) {
					totalPx += targetSize[i];
				}

				var xtraPx:Number = (_size - totalPx) / len;
				for (i = 0; i < len; i++) {
					targetSize[i] += xtraPx;
				}
			}
			
			killTweens();
			if (_tweens == null && tweenSecs > 0) {
				_tweens = new Array();
			}
			
			var bpos:Number = pos;
			var bsize:Number = 0;
			var propPos:String = (direction == "vertical") ? "y" : "x";
			var propSize:String = (direction == "vertical") ? "height" : "width";
			for (i = 0; i < len; i++) {
				if (roundCoords) {
					bpos = Math.floor(bpos);
					bsize = (len == len - 1) ? Math.ceil(targetSize[i]) : Math.floor(targetSize[i]);
				} else {
					bsize = targetSize[i];
				}
				var altProp:String = (direction == "vertical") ? "width" : "height";
				var altScale:Number = (direction == "vertical") ? (bsize / _btnRects[i].height) : (bsize / _btnRects[i].width);
				var altSize:Number = altScale * _btnRects[i][altProp];
				if (roundCoords) {
					altSize = Math.floor(altSize);
				}				
				
				if (tweenSecs == 0) {
					_btns[i][propPos] = bpos;
					_btns[i][propSize] = bsize;
					_btns[i][altProp] = altSize;
				} else {
					_tweens.push(new Tween(_btns[i], propPos, ease, _btns[i][propPos], bpos, tweenSecs, true));
					_tweens.push(new Tween(_btns[i], propSize, ease, _btns[i][propSize], bsize, tweenSecs, true));
					_tweens.push(new Tween(_btns[i], altProp, ease, _btns[i][altProp], altSize, tweenSecs, true));
				}
				bpos += bsize + _margins[i];
			}
		}
		
		
		protected function getBtnSize(index:int):Number {
			return (direction == "vertical") ? _btnRects[index].height : _btnRects[index].width;
		}
		
		
		
		
		protected function killTweens():void {
			if (_tweens == null) return;
			var len:int = _tweens.length;
			for (var i:int = 0; i < len; i++) {
				_tweens[i].stop();
				_tweens[i] = null;
			}
			_tweens.splice(0, len);
		}
		
		
		
		protected function getBtnIndex(btn:Object):int {
			var len:int = _btns.length;
			for (var i:int = 0; i < len; i++) {
				if (_btns[i] == btn) {
					return i;
				}
			}
			return -1;
		}
		
		
		
	}
}
