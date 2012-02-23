package {
	public class GameLogic {
		private var gameBoard:GameBoard;
				
		public static var HONEY0:int = 0x01;
		public static var HONEY1:int = 0x02;
		public static var HONEY2:int = 0x03;
		
		public static var FLOWER0:int = 0x14;
		public static var FLOWER1:int = 0x24;
		public static var FLOWER2:int = 0x34;
		public static var BEE:int = 0x04;

		
		private var honey:Array = [0,0,0];//new Array();
		private var turns:int;
		private var turnTime:int;

		public function GameLogic(gb:GameBoard, tt:int, t:int) {						
			gameBoard = gb;
			turns = t;
			turnTime = tt;
		}
		
		public function getHoney(i:int):int {
			return honey[i];
		}
		
		public function handleSequence(swipeSeq:SwipeSequence):int {
		
			var indexes:Vector.<int> = swipeSeq.getIndexes();
			
			var first:GameTile = null;
			var i:int = 0;
			while(!first) {
				first = gameBoard.getTile(indexes[i++]);
				if(i >= indexes.length)
					return 0;
			}
			var t:int = first.getTile().type;
			
			if(t >= HONEY0 && t <= HONEY2) {
				
				var bees:int = gameBoard.countTiles(BEE);
				var count:int = indexes.length - bees;
				if(count < 0) count = 0;
				var bonus:int = 0;
				if(count > 5)
					bonus += (count - 5) * 3;
				if(count > 8)
					bonus += (count - 8) * 5;
				
				honey[t-1] += count + bonus;
				
				trace("REMOVED", t, indexes.length, gameBoard.countTiles(t));
				if(indexes.length >= gameBoard.countTiles(t)) {
					// Collected all
					honey[t-1] += count * 5 + 100;
					return 3;
				}
				
				
				return 1;
			}
			
			honey[0] += indexes.length;
			
			// Handle attack
			 var flowers:int = 0;
			var bees:int = 0;
			for each(var i:int in indexes) {
				var gt:GameTile = gameBoard.getTile(i);
				if(gt) {
					if(gt.getTile().type == BEE)
						bees++;
					else
						flowers++;
				}
			}
			
			return (bees > 0 && flowers >= bees) > 0 ? 2 : 0; //(flowers >= bees);
		}
		
		public function doTurn():void {
			/*var bees:int = gameBoard.countTiles(BEE);
			for(var i:int = 0; i<3 ; i++) {
				honey[i] -= bees;
			}*/			
		}
			
		public function giveScore(score:int):void {
			honey[0] += score;
		}
	}
}