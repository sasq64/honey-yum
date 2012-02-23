package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class GameTile {
		private var bitmap:Bitmap;
		public function GameTile(t:Tile) {
			var tile:Tile = t;
			var bm:BitmapData = new BitmapData(t.dob.width, t.dob.height);
			var r:Rectangle = t.dob.getBounds(t.dob);
			var m:Matrix = new Matrix(1,0,0,1,-r.left, -r.top);
			bm.draw(t.dob, m);
			bitmap = new Bitmap(bm);
		}
		
		public function getDisplayObject():DisplayObject {
			return bitmap;
		}
	}
}