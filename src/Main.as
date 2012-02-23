package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	[SWF(width='1024', height='768', backgroundColor='#000000', frameRate=60)]
	public class Main extends Sprite {
		private var gameBoard:GameBoard;
		private var downX:Number;
		private var downY:Number;
		
		private var swipeSeq:SwipeSequence;
		private var doFill:Boolean;
		private var doFall:Boolean;
		private var tileSize:int;
		private var padding:int;
		private var boardWidth:int;
		private var boardHeight:int;
		
		public function Main() {

			var tiles:Array = [
				new Tile(new ballBlue(), 0),
				new Tile(new ballGreen(), 1),
				new Tile(new ballMagenta(), 2),
				new Tile(new ballOrange(), 3),
			];

			tileSize = 120;
			padding = 5;
			boardWidth = 6;
			boardHeight = 6;

			for each(var t:Tile in tiles) {
				(t.dob as MovieClip).stop();
				t.dob.scaleX = (tileSize - padding) / t.dob.width;
				t.dob.scaleY = (tileSize - padding) / t.dob.height;
			}
			
			
			gameBoard = new GameBoard(this, boardWidth, boardHeight, tileSize, tiles);
			swipeSeq = new SwipeSequence(gameBoard); //boardWidth, boardHeight, tileSize, tileSize);
			addEventListener(Event.ADDED_TO_STAGE, _init);
		}
		
		public function _init(e:Event = null):void {
			
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				swipeSeq.start(e.stageX, e.stageY);
			});
			stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
				swipeSeq.end();
				if(swipeSeq.length()) {
					gameBoard.remove(swipeSeq);
					//gameBoard.update(true);
					//gameBoard.fill();
					swipeSeq.clear()
					doFall = true;
				}
			});
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
				if(e.buttonDown)
					swipeSeq.add(e.stageX, e.stageY);
			});
			
			addEventListener(Event.ENTER_FRAME, onUpdate);
			
			gameBoard.update(true);
			
		}
		
		public function onUpdate(e:Event):void {
			
			if(doFill && !gameBoard.isMoving()) {
				gameBoard.update(true);
				gameBoard.fill();
				doFill = false;
			}

			if(doFall && !gameBoard.isMoving()) {
				gameBoard.update(true);
				gameBoard.fall();
				doFall = false;
				doFill = true;
			}
			
			gameBoard.update();
			
			
			
			if(swipeSeq.length() > 0) {
				trace(swipeSeq.toString());
			}
			
		}
	}
}