package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;

	public class Tile {
		public var dob:DisplayObject;
		public var type:int; 
		public function Tile(obj:Object, type:int) {
			
			var dob:DisplayObject;
			if(obj is BitmapData) {
				dob = new Bitmap(obj as BitmapData);
				(dob as Bitmap).smoothing = true;
			}  else {			
			  dob = (obj as DisplayObject);
			}
			this.dob = dob;
			this.type = type;
		}
	}
}