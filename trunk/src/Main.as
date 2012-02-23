package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Main extends Sprite {
		private var gameBoard:GameBoard;
		private var downX:Number;
		private var downY:Number;
		
		private var swipeSeq:SwipeSequence;
		private var doFill:Boolean;
		private var doFall:Boolean;
		
		public function Main() {

			var tiles:Array = [
				new Tile(new ballBlue()),
				new Tile(new ballGreen()),
				new Tile(new ballMagenta()),
				new Tile(new ballOrange()),
			];
			
			for each(var t:Tile in tiles) {
				(t.dob as MovieClip).stop();
			}
			
			gameBoard = new GameBoard(this,6,6, tiles);
			swipeSeq = new SwipeSequence(6, 6, 40, 40);
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