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
		
		public function Main() {

			var tiles:Array = [
				new Tile(new ballBlue()),
				new Tile(new ballGreen()),
				new Tile(new ballMagenta()),
				new Tile(new ballOrange()),
			];
			
			gameBoard = new GameBoard(6,6, tiles);
			swipeSeq = new SwipeSequence(6, 6, 40, 40);
			addEventListener(Event.ADDED_TO_STAGE, _init);
		}
		
		public function _init(e:Event = null):void {
			
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				swipeSeq.start(e.stageX, e.stageY);
			});
			stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
				swipeSeq.end();
			});
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
				if(e.buttonDown)
					swipeSeq.add(e.stageX, e.stageY);
			});
			
			addEventListener(Event.ENTER_FRAME, onUpdate);
			
			
			
			
			gameBoard.addChildren(this);
		}
		
		public function onUpdate(e:Event):void {
			
			if(swipeSeq.length() > 0) {
				trace(swipeSeq.toString());
			}
			
		}
	}
}