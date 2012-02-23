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

		public function GameLogic(gb:GameBoard) {						
			gameBoard = gb;
		}
		
		public function getHoney(i:int):int {
			return honey[i];
		}
		
		public function handleSequence(swipeSeq:SwipeSequence):Boolean {
		
			var indexes:Vector.<int> = swipeSeq.getIndexes();
			
			var first:GameTile = gameBoard.getTile(indexes[0]);
			var t:int = first.getTile().type;
			
			if(t >= HONEY0 && t <= HONEY2) {
				
				var bees:int = gameBoard.countTiles(BEE);
				var count:int = indexes.length - bees;
				
				var bonus:int = 0;
				if(indexes.length > 5)
					bonus += (count - 5) * 3;
				if(indexes.length > 8)
					bonus += (count - 8) * 5;
				
				honey[t-1] += count + bonus;
				
				return true;
			}	
			
			// Handle attack
			/* var flowers:int = 0;
			var bees:int = 0;
			for each(var i:int in indexes) {
				var gt:GameTile = gameBoard.getTile(i);				
				if(gt.getTile().type == BEE)
					bees++;
				else
					flowers++;
			} */
			
			return true; //(flowers >= bees);
		}
		
		public function doDamage():void {
			/*var bees:int = gameBoard.countTiles(BEE);
			for(var i:int = 0; i<3 ; i++) {
				honey[i] -= bees;
			}*/			
		}
	}
}