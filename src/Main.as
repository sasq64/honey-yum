package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
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
		private var gameLogic:GameLogic;
		private var gameBoardContainer:MovieClip;
		private var lineContainer:MovieClip;				
		private var honeyText:Array;
		
		public function Main() {

			var tiles:Array = [
				new Tile(new balloon(), GameLogic.FLOWER),
				new Tile(new sealionHead(), GameLogic.BEE),
				new Tile(new ballGreen(), GameLogic.HONEY0),
				new Tile(new ballBlue(), GameLogic.HONEY1),
				new Tile(new ballOrange(), GameLogic.HONEY2),
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
					
			gameBoardContainer = new MovieClip();
			addChild(gameBoardContainer);
			
			lineContainer = new MovieClip();
			addChild(lineContainer);						
			
			gameBoard = new GameBoard(gameBoardContainer, lineContainer, boardWidth, boardHeight, tileSize, tiles);
			swipeSeq = new SwipeSequence(gameBoard); //boardWidth, boardHeight, tileSize, tileSize);
			
			gameLogic = new GameLogic(gameBoard);
			
			honeyText = [ new TextField(), new TextField(), new TextField() ];
			var i:int = 0;
			for each(var tf:TextField in honeyText) {
				tf.y = 20;
				tf.x = 50 + 100 * i++;
				tf.defaultTextFormat = new TextFormat("Arial", 32, 0xffffffff, true);
				tf.mouseEnabled = false;
				tf.type = TextFieldType.DYNAMIC;
				tf.text = '0';
				tf.textColor = 0xffffffff;
				addChild(tf);
			}

			
			addEventListener(Event.ADDED_TO_STAGE, _init);
		}
		
		public function _init(e:Event = null):void {
			
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				swipeSeq.start(e.stageX, e.stageY);
			});
			stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
				swipeSeq.end();
				if(swipeSeq.length()) {
					
					if(gameLogic.handleSequence(swipeSeq)) {
						gameBoard.remove(swipeSeq);
						//gameBoard.update(true);
						//gameBoard.fill();
						swipeSeq.clear()
						doFall = true;
					}
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
			gameBoard.drawLine(swipeSeq);					
			
			
			if(doFill && !gameBoard.isMoving()) {
				gameLogic.doDamage();
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
			
			for(var i:int = 0; i<3; i++) {
				honeyText[i].text = gameLogic.getHoney(i).toString();
			}
			
			
			if(swipeSeq.length() > 0) {
				trace(swipeSeq.toString());
			}
			
		}
	}
}