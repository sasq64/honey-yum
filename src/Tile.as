package
{
	import flash.display.DisplayObject;

	public class Tile {
		public var dob:DisplayObject;
		public var type:int; 
		public function Tile(dob:DisplayObject, type:int) {
			this.dob = dob;
			this.type = type;
		}
	}
}