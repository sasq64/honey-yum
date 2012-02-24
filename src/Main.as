package
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.system.Security;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	[SWF(width='1024', height='768', backgroundColor='#000000', frameRate=60)]
	public class Main extends Sprite {

		// SETTINGS
		private var boardHeight:int = 6;
		private var boardWidth:int = 6;
		private var turnTime:int = 20;
		private var turns:int = 10;

		
		private var gameBoard:GameBoard;
		private var downX:Number;
		private var downY:Number;
		
		private var swipeSeq:SwipeSequence;
		private var doFill:Boolean;
		private var doFall:Boolean;
		private var tileSize:int;
		private var padding:int;
		private var gameLogic:GameLogic;
		private var gameBoardContainer:MovieClip;
		private var lineContainer:MovieClip;				
		private var honeyText:Array;
		private var effects:MovieClip;

		private var frame:int = 0;
		private var seconds:int;
		
		public static const FPS:int = 60;
		private var nextTurn:int;
		/*private var turnText:TextField;
		private var timeText:TextField;
		private var scoreText:TextField; */
		
		private var swipeType:int;
		private var scorePanel:Score_Turn_Time;
		private var offsX:int;
		private var offsY:int;
		private var bonusText:TextField;
		private var gameOver:Boolean;
		private var gameStart:Boolean;
		private var gameIntro:Boolean;
		private var logo:Bitmap;
		private var swipeOn:Boolean;
		private var boardBack:Bitmap;
		private var screenWidth:uint;
		private var screenHeight:uint;
		
		public static const DO_FULLSCREEN:Boolean = true;
		private var background:Bitmap;
		private var ropeFrame:rope_frame;

		public function Main() {

			Security.allowDomain("*");

			if(DO_FULLSCREEN) {
				screenWidth = stage.fullScreenWidth;
				screenHeight = stage.fullScreenHeight;
				stage.fullScreenSourceRect = new Rectangle(0,0,screenWidth,screenHeight);
				stage.displayState = StageDisplayState.FULL_SCREEN;
			} else {
				screenWidth = stage.stageWidth;
				screenHeight = stage.stageHeight;
			}
			
			addEventListener(Event.ADDED_TO_STAGE, _init);
		
		}
		
		private function onFullScreen(event:Event):void {
		}
		
		private function addTiles():void {
		}
		
		private function setupStage():void {
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
		
		private function endSwipe(force:Boolean = false):void {
			swipeSeq.end();
			if(swipeSeq.length() >= 3) {
				
				swipeType = gameLogic.handleSequence(swipeSeq);
				if(swipeType) {
					gameBoard.remove(swipeSeq);
					
					var len:int = swipeSeq.getIndexes().length;
					var seq:Vector.<int> = swipeSeq.getIndexes();
					
					for (var i:int=0; i<len; i++) {	
						var tileNo:int = seq[i];

						var x:int = gameBoard.getPosition(tileNo).x;
						var y:int = gameBoard.getPosition(tileNo).y;

						var effect:MovieClip;
						if (swipeType == 3) {
							effect = new large_EFFECT();							
							effect.x = x;
							effect.y = y;														
						} else if (len < 8) {
							effect = new small_EFFECT();
							effect.x = x;
							effect.y = y + (tileSize/2);
							effect.scaleX = tileSize / (effect.width*3);
							effect.scaleY = tileSize / (effect.height*3);							
						} else if (len >= 8) {
							effect = new medium_EFFECT();							
							effect.x = x;
							effect.y = y;							
						}
						// effect.play();
						effect.gotoAndPlay(Math.round(Math.random() * 10));
						effects.addChild(effect);
						
						if (i == (len-1)) {
							bonusText.x = offsX + x;
							bonusText.y = offsY + y;
							bonusText.alpha = 1;
							bonusText.scaleX = 0.6;
							bonusText.scaleY = 0.6;							
							bonusText.visible = true;
							bonusText.text = gameLogic.getLastScore() + "";
							TweenLite.to(bonusText, 1, 
								{ x:offsX + x+50, alpha:0.7, scaleX: 1.5, scaleY: 1.5, onComplete:function():void {
									bonusText.visible = false;
								}});
						}						
					}
					
					TweenLite.to(effects, 2, {  onComplete:function():void {
						while(effects.numChildren)
							effects.removeChildAt(0);
					}});
					
					//gameBoard.update(true);
					//gameBoard.fill();
					doFall = true;
				}
				turns--;
				nextTurn = seconds + turnTime;
			} else if(force) {
				turns--;
				nextTurn = seconds + turnTime;
			}
			swipeSeq.clear();			
		}
		
		public function handleKeys(e:Event):void {
			var ke:KeyboardEvent = e as KeyboardEvent;
			var cc:String = String.fromCharCode(ke.charCode);
			switch(ke.keyCode) {
				case Keyboard.Q:
				case Keyboard.ESCAPE:
					System.exit(0);
					break;
			}
		}

		public function _init(e:Event = null):void {
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
			
			
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
			
			//boardWidth = 6;
			//boardHeight = 6;
			
			tileSize = (screenHeight - 150) / boardHeight;
			padding = 20;
			//turnTime = 20;
			//turns = 10;
			
			offsX = (screenWidth - tileSize * boardWidth)/2;
			offsY = screenHeight/15;

			
			var hb:honeyBack = new honeyBack();
			background = new Bitmap(hb);
			background.smoothing = true;
			background.scaleX = screenWidth / background.width;
			background.scaleY = screenHeight / background.height;
			addChild(background);
			
			
			var bm:Bitmap = new Bitmap(new backgr_square());
			bm.smoothing = true;
			//bm.alpha = 0.1;
			
			var bd:BitmapData = new BitmapData(tileSize * boardWidth, tileSize * boardHeight, true, 0);
			var sx:Number = tileSize / bm.width;
			var sy:Number = tileSize / bm.height;
			
			for(var y:int=0; y<boardHeight; y++) {
				for(var x:int=0; x<boardWidth; x++) {
					
					var m:Matrix = new Matrix(sx,0,0,sy,x*tileSize,y*tileSize);					
					bd.draw(bm, m);
				}
			}
			
			
			boardBack = new Bitmap(bd);
			//boardBack.alpha = 0.8;
			boardBack.x = offsX - padding/2;
			boardBack.y = offsY - padding/2;
			boardBack.visible = false;
			addChild(boardBack);
			
			ropeFrame = new rope_frame();
			ropeFrame.scaleX = boardBack.width * 1.03 / ropeFrame.width;
			ropeFrame.scaleY = boardBack.height * 1.03 / ropeFrame.height;
			ropeFrame.x = boardBack.x + boardBack.width / 2;
			ropeFrame.y = boardBack.y + boardBack.height / 2;
			addChild(ropeFrame);
			ropeFrame.visible = false;
			
			
			for each(var t:Tile in tiles) {
				if(t.dob is MovieClip)
					(t.dob as MovieClip).stop();
				t.dob.scaleX = (tileSize - padding) / t.dob.width;
				t.dob.scaleY = (tileSize - padding) / t.dob.height;
			}
			
			gameBoardContainer = new MovieClip();
			gameBoardContainer.x = offsX;
			gameBoardContainer.y = offsY;
			addChild(gameBoardContainer);
			
			offsX -= padding/2;
			offsY -= padding/2;
			
			lineContainer = new MovieClip();
			lineContainer.x = offsX;
			lineContainer.y = offsY;
			addChild(lineContainer);						
			
			gameBoard = new GameBoard(gameBoardContainer, lineContainer, boardWidth, boardHeight, tileSize, tiles);
			swipeSeq = new SwipeSequence(gameBoard); //boardWidth, boardHeight, tileSize, tileSize);
			
			gameLogic = new GameLogic(gameBoard, turnTime, turns);
			
			effects = new MovieClip();
			effects.x = offsX;
			effects.y = offsY;
			addChild(effects);
			
			scorePanel = new Score_Turn_Time();
			scorePanel.x = 300 + (screenWidth - scorePanel.width) / 2;
			scorePanel.y = screenHeight - scorePanel.height + 20;
			
			bonusText = makeTextField();
			bonusText.width = 100;	
			bonusText.visible = false;
			addChild(bonusText);
			
			gameBoard.setHoneyTarget(0, scorePanel.y);
			
			//mc.play();
			addChild(scorePanel);
			
			this.stage.addEventListener(Event.RESIZE, function(e:Event) {
				setupStage();
			});
			
			
			gameIntro = true;
			logo = new Bitmap(new intro_logo());
			logo.x = (screenWidth - logo.width) / 2;
			logo.y = (screenHeight - logo.height) / 2;
			addChild(logo);
			
			
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				
				if(gameIntro) {
					gameStart = true;
					gameIntro = false;
					removeChild(logo);
					//background.visible = false;
					boardBack.visible = true;
					ropeFrame.visible = true;

					gameBoard.update(true);
					nextTurn = seconds + turnTime;
					return;
				}
				
				if(gameBoard.isMoving()) return;
				swipeOn = true;
				swipeSeq.start(e.stageX - offsX, e.stageY - offsY);
			});
			stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
				if(swipeOn) {
					swipeOn = false;
					endSwipe();
				}
			});
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
				if(e.buttonDown && swipeOn)
					swipeSeq.add(e.stageX - offsX, e.stageY - offsY);
			});
			
			addEventListener(Event.ENTER_FRAME, onUpdate);
			
			//gameBoard.update(true);
			
			nextTurn = turnTime;
			
		}
				
		public function onUpdate(e:Event):void {
			
			frame++;
			
			seconds = (frame / FPS);
			
			if(gameIntro) {
				return;
			}

			if(turns <= 0 && !gameBoard.isMoving()) {
								
				if(!gameOver) {
					gameOver = true;
					removeChild(lineContainer);					
					var bd:Bitmap = new Bitmap(new game_over());
					bd.x = (screenWidth - bd.width) / 2;
					bd.y = (screenHeight - bd.height) / 2;
					addChild(bd);				
					
					scorePanel.turn.text = "0";
					scorePanel.time.text = "";					
				}
				
				return;
			}

			
			gameBoard.drawLine(swipeSeq, effects, tileSize / 8);			
			
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
				if(swipeType != 3) {						
					doFill = true;
				} else {
					var xc:int = gameBoard.countHoney();
					if(xc == 0) {
						trace("#### CLEAR ALL!");
						gameLogic.giveScore(1000);
						doFill = true;
					}
				}
				doFall = false;
			}
			
			gameBoard.update();
			
			var score:int = gameLogic.getScore();
			
			scorePanel.score.text = score.toString();
			
			scorePanel.turn.text = turns.toString();
			scorePanel.time.text = (nextTurn - seconds).toString();
			
			if(nextTurn <= seconds) {
				endSwipe(true);
			}
			
			
			//if(swipeSeq.length() > 0) {
			//	trace(swipeSeq.toString());
			//}
			
		}
	}
}