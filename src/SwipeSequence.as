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
		private var gameBoard:GameBoard;
		private var lastType:int;

		public function SwipeSequence(gb:GameBoard) {//w:int, h:int, tw:int, th:int) {
			
			gameBoard = gb;
			width = gb.getWidth();
			height = gb.getHeight();
			tileWidth = tileHeight = gb.getTileSize();			
			//width = w;
			//height = h;
			//tileWidth = tw;
			//tileHeight = th;
			seq = new Vector.<int>();
		}
		
		private static var padding:Number = 0.3;
		
		private function calc(x:int, y:int):int {
			var tx:int = (x / tileWidth);
			var ty:int = (y / tileHeight);
			
			var dx:Number = (x / tileWidth) - tx;
			var dy:Number = (y / tileWidth) - ty;
			
			if(dx < padding || dx > 1-padding || dy < padding || dy > 1-padding)
				return -1;
			
			if(tx >= 0 && tx < width && ty >= 0 && ty < height) {
				return tx + ty * width;
			}
			
			return -1;
		}
		
		public function start(x:Number, y:Number):void {
			seq = new Vector.<int>();
			lastTile = -1;
			lastType = -1;
			add(x,y);
		}
		
		public function add(x:Number, y:Number):void {
			var tileNo:int = calc(x,y);
			if(tileNo >= 0 && tileNo != lastTile) {

				if(lastTile >= 0) {
					var x0:int = (tileNo % width);
					var y0:int = (tileNo / width);
					var x1:int = (lastTile % width);
					var y1:int = (lastTile / width);
					
					if(Math.abs(x0-x1) > 1 || Math.abs(y0-y1) > 1)
						return;
				}

				var gt:GameTile = gameBoard.getTile(tileNo);
				
				if(!gt) return;
				
				if(lastType >= 0 && (gt.getTile().type & 0xf) != lastType) {
					return;
				}
				
				lastType = gt.getTile().type & 0xf;
				
				
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