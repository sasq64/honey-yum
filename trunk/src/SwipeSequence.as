package
{
	public class SwipeSequence
	{
		private var width:int;
		private var height:int;
		private var tileWidth:int;
		private var tileHeight:int;
		private var seq:Vector.<int>;
		private var lastTile:int;

		public function SwipeSequence(w:int, h:int, tw:int, th:int) {
			width = w;
			height = h;
			tileWidth = tw;
			tileHeight = th;
			seq = new Vector.<int>();
		}
		
		private function calc(x:int, y:int):int {
			var tx:int = (x / tileWidth);
			var ty:int = (y / tileHeight);
			if(tx >= 0 && tx < width && ty >= 0 && ty < height) {
				return tx + ty * width;
			}
			return -1;
		}
		
		public function start(x:Number, y:Number):void {
			seq = new Vector.<int>();
			lastTile = -1;
			add(x,y);
		}
		
		public function add(x:Number, y:Number):void {
			var tileNo:int = calc(x,y);
			if(tileNo >= 0 && tileNo != lastTile) {
				
				for(var i:int=0; i<seq.length; i++) {
					if(seq[i] == tileNo) {
						seq = seq.slice(0, i);
						return;
					}
				}
				
				seq.push(tileNo);				
				lastTile = tileNo;
			}
		}

		public function length():int {
			return seq.length;
		}
		
		public function toString():String {
			return seq.toString();
		}
		
		public function end():void {
		}
		
		public function getIndexes():Vector.<int> {
			return seq;
		}
		
		public function clear():void {
			seq = new Vector.<int>();
		}
	}
}