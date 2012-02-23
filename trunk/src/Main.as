package
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
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
		private var effects:MovieClip;
		private var turnTime:int;
		private var turns:int;

		private var frame:int = 0;
		private var seconds:int;
		
		public static const FPS:int = 60;
		private var nextTurn:int;
		private var turnText:TextField;
		private var timeText:TextField;
		private var scoreText:TextField;
		private var swipeType:int;

		public function Main() {

			var tiles:Array = [
				new Tile(new honeyJar_blue, GameLogic.HONEY0),
				new Tile(new honeyJar_green(), GameLogic.HONEY1),
				new Tile(new honeyJar_red(), GameLogic.HONEY2),
				new Tile(new flower_1(), GameLogic.FLOWER0),
				new Tile(new flower_2(), GameLogic.FLOWER1),
				new Tile(new bee(), GameLogic.BEE) /*,
				new Tile(new balloon(), GameLogic.FLOWER0),
				new Tile(new sealionHead(), GameLogic.BEE),
				new Tile(new ballGreen(), GameLogic.HONEY0),
				new Tile(new ballBlue(), GameLogic.HONEY1),
				new Tile(new ballOrange(), GameLogic.HONEY2) */
			];

			tileSize = 100;
			padding = 5;
			boardWidth = 6;
			boardHeight = 6;
			turnTime = 10;
			turns = 10;
			
			var bm:Bitmap = new Bitmap(new background());
			bm.smoothing = true;
			bm.scaleX = stage.stageWidth / bm.width;
			bm.scaleY = stage.stageHeight / bm.height;

			//addChild(bm);
						
			for each(var t:Tile in tiles) {
				if(t.dob is MovieClip)
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
			
			gameLogic = new GameLogic(gameBoard, turnTime, turns);
			
			/*honeyText = [ makeTextField(), makeTextField(), makeTextField() ];
			var i:int = 0;
			for each(var tf:TextField in honeyText) {
				tf.y = 20;
				tf.x = 50 + 100 * i++;
				addChild(tf);
			}*/
			
			turnText = makeTextField();
			turnText.x = 10;
			turnText.y = 720;
			addChild(turnText);
			
			timeText = makeTextField();
			timeText.x = 210;
			timeText.y = 720;
			addChild(timeText);
			
			scoreText = makeTextField();
			scoreText.x = 900;
			scoreText.y = 720;
			addChild(scoreText);

			
			effects = new MovieClip();
			addChild(effects);
			
			//var mc:MovieClip = new effect_1();
			//mc.x = 100;
			//mc.y = 100;
			//mc.play();
			//addChild(mc);

			
			addEventListener(Event.ADDED_TO_STAGE, _init);
		}
		
		private function makeTextField():TextField {
			
			var tf:TextField = new TextField();			
			tf.defaultTextFormat = new TextFormat("Arial", 32, 0xffffffff, true);
			tf.mouseEnabled = false;
			tf.type = TextFieldType.DYNAMIC;
			tf.text = '0';
			tf.textColor = 0xffffffff;
			return tf;
		}
		
		private function endSwipe():void {
			swipeSeq.end();
			if(swipeSeq.length() >= 3) {
				
				swipeType = gameLogic.handleSequence(swipeSeq);
				if(swipeType) {
					gameBoard.remove(swipeSeq);
					
					var len:int = swipeSeq.getIndexes().length;
					
					for each(var i:int in swipeSeq.getIndexes()) {							
						var x:int = (i % boardWidth) * tileSize;
						var y:int = (i / boardHeight) * tileSize;

						var effect:MovieClip;
						if (swipeType == 3) {
							effect = new large_EFFECT();							
							effect.x = x + (tileSize/2);
							effect.y = y;														
						} else if (len < 8) {
							effect = new small_EFFECT();
							effect.x = x + (tileSize/2);
							effect.y = y + (tileSize/2);
						} else if (len >= 8) {
							effect = new medium_EFFECT();							
							effect.x = x + (tileSize/2);
							effect.y = y;							
						}
						effect.play();
						effects.addChild(effect);
					}
					
					TweenLite.to(effects, 0.9, {  onComplete:function():void {
						while(effects.numChildren)
							effects.removeChildAt(0);
					}});
					
					//gameBoard.update(true);
					//gameBoard.fill();
					doFall = true;
				}
			}
			swipeSeq.clear();
			
			turns--;
			nextTurn = seconds + turnTime;
		}
		
		public function _init(e:Event = null):void {
			
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				swipeSeq.start(e.stageX, e.stageY);
			});
			stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
				endSwipe();
			});
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
				if(e.buttonDown)
					swipeSeq.add(e.stageX, e.stageY);
			});
			
			addEventListener(Event.ENTER_FRAME, onUpdate);
			
			gameBoard.update(true);
			
			nextTurn = turnTime;
			
		}
				
		public function onUpdate(e:Event):void {
			
			frame++;
			
			seconds = (frame / FPS);
			
			

			gameBoard.drawLine(swipeSeq, effects);			
			
			if(doFill && !gameBoard.isMoving()) {
				gameBoard.update(true);
				gameBoard.fill(swipeType == 1);
				doFill = false;
			}

			if(doFall && !gameBoard.isMoving()) {
				gameBoard.update(true);
				if(swipeType == 1)
					gameBoard.rise();
				else
					gameBoard.fall();
				doFall = false;
				doFill = true;
			}
			
			gameBoard.update();
			
			var score:int = 0;
			for(var i:int = 0; i<3; i++) {
				score += gameLogic.getHoney(i);
				//honeyText[i].text = gameLogic.getHoney(i).toString();
			}
			
			scoreText.text = score.toString();

			
			turnText.text = turns.toString();
			timeText.text = (nextTurn - seconds).toString();
			
			if(nextTurn <= seconds) {
				endSwipe();
			}
			
			
			if(swipeSeq.length() > 0) {
				trace(swipeSeq.toString());
			}
			
		}
	}
}