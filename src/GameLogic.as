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

		public static var SWIPE_NONE:int = 0;
		public static var SWIPE_HONEY:int = 1;
		public static var SWIPE_BEES:int = 2;
		public static var SWIPE_ALL:int = 3;
		
		private var totalScore:int;
		private var turns:int;
		private var turnTime:int;
		private var lastScore:int;
		private var lastBonus:int;
		private var lastDeduct:int;

		public function GameLogic(gb:GameBoard, tt:int, t:int) {						
			gameBoard = gb;
			turns = t;
			turnTime = tt;
			totalScore = 0;
		}
		
		public function getScore():int {
			return totalScore;
		}
		
		public function getLastScore():int {
			return lastScore;
		}
		
		public function getLastBonus():int {
			return lastBonus;
		}

		public function getLastDeduct():int {
			return lastDeduct;
		}
public function handleSequence(swipeSeq:SwipeSequence):int {
		
			var indexes:Vector.<int> = swipeSeq.getIndexes();
			
			var first:GameTile = null;
			var i:int = 0;
			
			lastScore = 0;
			lastBonus = 0;
			lastDeduct = 0;
			
			while(!first) {
				first = gameBoard.getTile(indexes[i++]);
				if(i >= indexes.length)
					return SWIPE_NONE;
			}
			var t:int = first.getTile().type;
			
			if(t >= HONEY0 && t <= HONEY2) {
				
				var bees:int = gameBoard.countTiles(BEE);
				var count:int = indexes.length - bees;
				lastDeduct = bees;
				if(count < 0) count = 0;
				if(count > 5)
					lastBonus += (count - 5) * 3;
				if(count > 8)
					lastBonus += (count - 8) * 5;
				
				 lastScore = count + lastBonus;
				
				trace("REMOVED", t, indexes.length, gameBoard.countTiles(t));
				if(indexes.length >= gameBoard.countTiles(t)) {
					// Collected all
					lastBonus += count * 5 + 100;
					lastScore += count * 5 + 100;
					return SWIPE_ALL;
				}
				
				totalScore += lastScore;
				
				
				return SWIPE_HONEY;
			}
			
			
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
			
			if(bees > 0 && flowers >= bees) {
				lastScore = indexes.length;
				totalScore += lastScore;
				return SWIPE_BEES;
			}
			return SWIPE_NONE;
		}
		
		public function doTurn():void {
			/*var bees:int = gameBoard.countTiles(BEE);
			for(var i:int = 0; i<3 ; i++) {
				honey[i] -= bees;
			}*/			
		}
			
		public function giveScore(score:int):void {
			totalScore += score;
		}
	}
}