package {
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.EaseLookup;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class GameTile {
		private var bitmap:Bitmap;
		private var tile:Tile;
		//public var empty:Boolean;
		public var moving:int;
		public var removeMe:Boolean;
		public var dx:Number;
		public var dy:Number;
		public function GameTile(t:Tile) {
			tile = t;
			var bm:BitmapData = new BitmapData(t.dob.width, t.dob.height, true, 0);
			var r:Rectangle = t.dob.getBounds(t.dob);
			var m:Matrix = new Matrix(t.dob.scaleX,0,0,t.dob.scaleY,-r.left * t.dob.scaleX , -r.top * t.dob.scaleY);
			bm.draw(t.dob, m);
			bitmap = new Bitmap(bm);
			//empty = false;
			dx = dy = 0;
			moving = 0;
		}
		
		public function getDisplayObject():DisplayObject {
			return bitmap;
		}
		
		public function setTileX(t:Tile):void {
			tile = t;
			var bm:BitmapData = new BitmapData(t.dob.width, t.dob.height);
			var r:Rectangle = t.dob.getBounds(t.dob);
			var m:Matrix = new Matrix(1,0,0,1,-r.left, -r.top);
			bm.draw(t.dob, m);
			bitmap = new Bitmap(bm);
			//empty = false;
		}
		
		public function update(parent:DisplayObjectContainer, x:int, y:int):void {
			bitmap.x = x + dx;
			bitmap.y = y + dy;
			parent.addChild(bitmap);
			//trace(x, y);
		}
		
		public function getTile():Tile {
			return tile;
		}
		
		public function fall(dist:Number):void {

			var that:GameTile = this;
			moving |= 1;
			dy -= dist;
			TweenLite.to(this, 1.0, { dy:0, ease:Bounce.easeOut, onComplete:function():void {
				that.moving &= ~1;
			}});
		}
		
		public function moveTo(x:int, y:int, removeIt:Boolean = false):void {
			moving |= 2;
			TweenLite.to(this, 1.0, { dx:x, dy:y, ease:Back.easeOut, onCompleteParams:[this], onComplete:function(gt:GameTile):void {
				gt.moving &= ~2;
				gt.removeMe = removeIt;
			}});
			
		}

		public function fadeTo(to:int):void {
			this.moving |= 4;
			TweenLite.to(bitmap, 1.0, { scaleX:0, scaleY:0, ease:Back.easeOut, onCompleteParams:[this], onComplete:function(gt:GameTile):void {
				gt.moving &= ~4;
			}});
		}

			
		public function remove():void {
			this.moving |= 8;
			TweenLite.to(bitmap, 0.5, { scaleX:0, scaleY:0, onCompleteParams:[this], onComplete:function(gt:GameTile):void {
				trace("COMPLETE");
				gt.moving &= ~8;
				gt.removeMe = true;
			}});			
			//TweenLite.to(this, 0.5, { dy:(bitmap.width/2), dx:(bitmap.height/2) });
		}
		
	}
}