package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class LineTile {
		private var bitmap:Bitmap;
		private var tile:Tile;
		
		public function LineTile(t:Tile) {
			tile = t;
			var bm:BitmapData = new BitmapData(t.dob.width, t.dob.height, true, 0);
			var r:Rectangle = t.dob.getBounds(t.dob);
			var m:Matrix = new Matrix(t.dob.scaleX,0,0,t.dob.scaleY,-r.left * t.dob.scaleX , -r.top * t.dob.scaleY);
			bm.draw(t.dob, m);
			bitmap = new Bitmap(bm);
		}
		
		public function getDisplayObject():DisplayObject {
			return bitmap;
		}
		
		public function update(parent:DisplayObjectContainer, x:int, y:int):void {
			bitmap.x = x;
			bitmap.y = y;			
			parent.addChild(bitmap);
		}
		
		public function remove():void {
			
		}
	}
}