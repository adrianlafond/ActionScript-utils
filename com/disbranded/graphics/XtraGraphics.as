/**
* com.disbranded.graphics.XtraGraphics
*
* methods:
*  drawStar(x:Number = 0, y:Number = 0, radius:Number = 50, spokes:Number = 5, obtuseness:Number = 0.39, rotation:Number = -1.5707963267948966):void
*  drawPolygon(x:Number = 0, y:Number = 0, radius:Number = 50, sides:uint = 5, rotation:Number = NaN):void
*  drawParallelogram(x:Number, y:Number, width:Number, height:Number, skewHorizontal:Number = 0, skewVertical:Number = 0):void {
*  drawRect() == drawParallelogram(), just with a shorter name
*
* author: Adrian Lafond / Disbranded
*/


package com.disbranded.graphics {
	import flash.display.*;
	import flash.geom.*;


    public class XtraGraphics extends Object {
	
		private var _graphics:Graphics;
    

        public function XtraGraphics(g:Graphics) {
            super();
			_graphics = g;
        }


		/**
		* Star
		* rotation -1.5707963267948966 == ( -90 * Math.PI / 180 )
		*/
		public function drawStar(x:Number = 0, y:Number = 0, radius:Number = 50, spokes:Number = 5, obtuseness:Number = 0.39, rotation:Number = -1.5707963267948966):void {
	    	var radians:Number = Math.PI * 2 / spokes;
	    	var innerRadius:Number = radius * obtuseness;
			var fn:Function;
	    	for (var i:uint=0; i<spokes; i++) {
				fn = (i == 0) ? _graphics.moveTo : _graphics.lineTo;
	    		if (i==0) {
	    			fn(Math.cos(radians * i + rotation) * radius + x, Math.sin(radians * i + rotation) * radius + y);
	    		} else {
	    			fn(Math.cos(radians * i + rotation) * radius + x, Math.sin(radians * i + rotation) * radius + y);
	    		}
	    		_graphics.lineTo(Math.cos(radians * i + radians / 2 + rotation) * innerRadius + x, Math.sin(radians * i + radians / 2 + rotation) * innerRadius + y);
	    	}
	    	_graphics.lineTo(Math.cos(rotation) * radius + x, Math.sin(rotation) * radius + y);
		}
		
		
		/**
		* Polygon
		*/
		public function drawPolygon(x:Number = 0, y:Number = 0, radius:Number = 50, sides:uint = 5, rotation:Number = NaN):void {
			var radians:Number = Math.PI * 2 / sides;
			if (isNaN(rotation)) {
				rotation = -90 * Math.PI / 180;
				if (sides % 2 == 0) {
					rotation -= radians / 2;
				}
			}
			_graphics.moveTo( Math.cos(rotation) * radius + x, Math.sin(rotation) * radius + y );
			for (var i:uint=1; i<sides; i++) {
				_graphics.lineTo( Math.cos(radians * i + rotation) * radius + x, Math.sin(radians * i + rotation) * radius + y );
			}
			_graphics.lineTo(Math.cos(rotation) * radius + x, Math.sin(rotation) * radius + y);
		}
		
		
		
		/**
		* Parallelogram
		* skewHorizontal and skewVertical are in degrees
		*/
		public function drawParallelogram(x:Number, y:Number, width:Number, height:Number, skewHorizontal:Number = 0, skewVertical:Number = 0):void {
			if (skewHorizontal == 0 && skewVertical == 0) {
				drawRect(x, y, width, height);
			} else {
				var TL:Point = new Point(x, y);
				var TR:Point = new Point(x + width, y);
				var BR:Point = new Point(x + width, y + height);
				var BL:Point = new Point(x, y + height);
				var pts:Array = [ TL, TR, BR, BL ];
				var radians:Number;
				var d:Number;
				var i:uint;
				
				if (skewHorizontal != 0) {
					radians = (skewHorizontal - 90) * Math.PI / 180;
					TL.x = BL.x + Math.cos(radians) * height;
					TR.x = TL.x + width;
					d = (x - TL.x) / 2;
					for (i=0; i<4; i++) {
						pts[i].x += d;
					}
				}
				
				if (skewVertical != 0) {
					radians = skewVertical * Math.PI / 180;
					TR.y = TL.y + Math.sin(radians) * width;
					BR.y = TR.y + height;
					d = (y - TR.y) / 2;
					for (i=0; i<4; i++) {
						pts[i].y += d;
					}
				}
				
				moveTo(TL.x, TL.y);
				lineTo(TR.x, TR.y);
				lineTo(BR.x, BR.y);
				lineTo(BL.x, BL.y);
				lineTo(TL.x, TL.y);
			}
		}
		

		
		
		/**
		* Functions of Graphics to make XtraGraphics can be used instead of Graphics.
		*/
		public function clear():void {
			_graphics.clear();
		}

		public function beginFill(color:uint, alpha:Number = 1.0):void {
			_graphics.beginFill(color, alpha);
		}

		public function beginBitmapFill(bitmap:BitmapData, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false):void {
			_graphics.beginBitmapFill(bitmap, matrix, repeat, smooth);
		}
		
		public function beginGradientFill(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = "pad", interpolationMethod:String = "rgb", focalPointRatio:Number = 0):void {
			_graphics.beginGradientFill(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);
		}
		
		public function endFill():void {
			_graphics.endFill();
		}
		
		public function lineStyle(thickness:Number, color:uint = 0, alpha:Number = 1.0, pixelHinting:Boolean = false, scaleMode:String = "normal", caps:String = null, joints:String = null, miterLimit:Number = 3):void {
			_graphics.lineStyle(thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit);
		}
		
		public function lineGradientStyle(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = "pad", interpolationMethod:String = "rgb", focalPointRatio:Number = 0):void {
			_graphics.lineGradientStyle(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);
		}
		
		public function moveTo(x:Number, y:Number):void {
			_graphics.moveTo(x, y);
		}
		
		public function lineTo(x:Number, y:Number):void {
			_graphics.lineTo(x, y);
		}
		
		public function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void {
			_graphics.curveTo(controlX, controlY, anchorX, anchorY);
		}
    
		public function drawCircle(x:Number, y:Number, radius:Number):void {
			_graphics.drawCircle(x, y, radius);
		}
		
		public function drawEllipse(x:Number, y:Number, width:Number, height:Number):void {
			_graphics.drawEllipse(x, y, width, height);
		}
		
				
		/**
		* Parallelogram called by shorter drawRect()
		* skewHorizontal and skewVertical are in degrees
		*/
		public function drawRect(x:Number, y:Number, width:Number, height:Number, skewHorizontal:Number = 0, skewVertical:Number = 0):void {
			if (skewHorizontal == 0 && skewVertical == 0) {
				_graphics.drawRect(x, y, width, height);
			} else {
				drawParallelogram(x, y, width, height, skewHorizontal, skewVertical);
			}
		}

		
		public function drawRoundRect(x:Number, y:Number, width:Number, height:Number, ellipseWidth:Number, ellipseHeight:Number):void {
			_graphics.drawRoundRect(x, y, width, height, ellipseWidth, ellipseHeight);
		}
    }
}