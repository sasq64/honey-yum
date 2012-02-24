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
		
		private static var padding:Number = 0.2;
		
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
		
		private function isSame(x0:int, y0:int, x1:int, y1:int):Boolean {
			
			var gt0:GameTile = gameBoard.getTile(x0+y0*width);
			var gt1:GameTile = gameBoard.getTile(x1+y1*width);
			
			//trace(x0,y0, "vs", x1, y1, "gives", gt0.getTile().type, gt1.getTile().type);
			
			return (!gt0 || !gt1 || ((gt0.getTile().type & 0xf) == (gt1.getTile().type & 0xf)));
		}
		
		public function add(x:Number, y:Number):void {
			var tileNo:int = calc(x,y);
			if(tileNo >= 0 && tileNo != lastTile) {

				if(lastTile >= 0) {
					
					var x0:int = (lastTile % width);
					var y0:int = (lastTile / width);
					var x1:int = (tileNo % width);
					var y1:int = (tileNo / width);
					
					//trace("######", lastTile, "TO", tileNo);
					// x0,x1 => x
					while(x0 != x1 || y0 != y1) {
						var dx:int = 0;
						var dy:int = 0;
						if(x0 < x1) // && isSame(x0,y0,x0+1,y0))
							dx=1;
						else if(x0 > x1) //&& isSame(x0,y0,x0-1,y0))
							dx=-1;
						if(y0 < y1) // && isSame(x0,y0,x0,y0+1))
							dy=1;
						else if(y0 > y1) // && isSame(x0,y0,x0,y0-1))
							dy=-1;
						
						//if(dx == 0 && dy == 0) return;

						if(!isSame(x0,y0, x0+dx, y0+dy)) return;
						
						//trace("###", dx, dy);
						
						
						x0 += dx;
						y0 += dy;
						
						tileNo = x0 + y0 * width;

						for(var i:int=0; i<seq.length; i++) {
							if(seq[i] == tileNo) {
								seq = seq.slice(0, i);
								return;
							}
						}
						
						seq.push(tileNo);				
						lastTile = tileNo;
					}
					
					return;
					
					//if(Math.abs(x0-x1) > 1 || Math.abs(y0-y1) > 1)
					//	return;
				}
/*
				var gt:GameTile = gameBoard.getTile(tileNo);
				
				if(gt) {				
					if(lastType >= 0 && (gt.getTile().type & 0xf) != lastType) {
						return;
					}
					lastType = gt.getTile().type & 0xf;
				} */ 
				for(var i:int=0; i<seq.length; i++) {
					if(seq[i] == tileNo) {
						seq = seq.slice(0, i);
						return;
					}
				}
				
				seq.push(tileNo);				
				lastTile = tileNo;
				trace("START TILE", tileNo);
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