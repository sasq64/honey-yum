package {
	public class GameLogic {
		private var gameBoard:GameBoard;
				
		public static var HONEY0:int = 0x01;
		public static var HONEY1:int = 0x02;
		public static var HONEY2:int = 0x03;
		
		public static var FLOWER:int = 0x04;
		public static var BEE:int = 0x14;

		
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
				
				var bonus:int = 0;
				if(indexes.length > 5)
					bonus += (indexes.length - 5) * 3;
				if(indexes.length > 8)
					bonus += (indexes.length - 8) * 5;
				
				honey[t-1] += indexes.length + bonus;
				
				return true;
			}	
			
			// Handle attack
			var flowers:int = 0;
			var bees:int = 0;
			for each(var i:int in indexes) {
				var gt:GameTile = gameBoard.getTile(i);				
				if(gt.getTile().type == FLOWER)
					flowers++;
				else if(gt.getTile().type == BEE)
					bees++;
			}
			
			return (flowers >= bees);
		}
		
		public function doDamage():void {
			var bees:int = gameBoard.countTiles(BEE);
			for(var i:int = 0; i<3 ; i++) {
				honey[i] -= bees;
			}
			
		}
	}
}