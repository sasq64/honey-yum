package {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.DisplacementMapFilterMode;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class GameBoard {
		
		private var width:int;
		private var height:int;
		private var tiles:Array;
		private var parent:DisplayObjectContainer;
		private var lineContainer:DisplayObjectContainer;		
		private var doUpdate:Boolean;
		private var gameTiles:Vector.<GameTile>;
		private var lineTiles:Vector.<LineTile>;		
		private var tileSize:int;
		private var dict:Dictionary;		
		
		public function getWidth():int { return width; }
		public function getHeight():int { return height; }
		public function getTileSize():int { return tileSize; }
		
		public function getTiles():Vector.<int> {
			
			for(var i:int=0; i<width*height; i++) {
				
			}
			return null;
		}
		
		public function getTile(i:int, j:int = -1):GameTile {
			if(j != -1) i += j*width;
			return gameTiles[i];
		}

		
		public function GameBoard(parent:DisplayObjectContainer, lineContainer:DisplayObjectContainer, w:int, h:int, tsize:int, tiles:Array) {
			width = w;
			height = h;
			this.tiles = tiles;
			this.parent = parent;
			this.lineContainer = lineContainer;
			tileSize = tsize;
			
			gameTiles = new Vector.<GameTile>(w*h);
			for(var i:int=0; i<w*h; i++) {				
				var r:int = (Math.random() * tiles.length);				
				gameTiles[i] = new GameTile(tiles[r]);
			}
			
			lineTiles = new Vector.<LineTile>(w*h);	
			
			dict = new Dictionary();
			var counter:int = 0;
			
			// Move to game board init
			for(var y:int=0; y<height; y++) {
				for(var x:int=0; x<width; x++) {
					dict[counter] = new Point(x, y);
					counter++;
				}
			}			
		}
		
		public function isMoving():Boolean {
			for(var i:int=0; i<width*height; i++) {
				if(gameTiles[i] && gameTiles[i].moving > 0) {
					trace("Tile ",i,"is moving", gameTiles[i].moving);
					return true;
				}
			}
			return false;
		}
		
		public function update(full:Boolean= false):void {
			
			if(!doUpdate && !full) {
				if(!isMoving()) return;
			}
			
			trace("## UPDATE");
			
			while(parent.numChildren)
				parent.removeChildAt(0);
			
			for(var y:int=0; y<height; y++) {
				for(var x:int=0; x<width; x++) {
					//var dob:DisplayObject = gameTiles[y*width+x].getDisplayObject();
					if(gameTiles[y*width+x]) {
						if(gameTiles[y*width+x].removeMe)
							gameTiles[y*width+x] = null;
						else
							gameTiles[y*width+x].update(parent, x*tileSize, y*tileSize);
					}
					if(lineTiles[y*width+x]) {
						lineTiles[y*width+x].update(lineContainer, x*tileSize, y*tileSize);						
					}					
					
					/*if(dob) {
						dob.x = x*40;
						dob.y = y*40;
						parent.addChild(dob);
					}*/
				}
			}
			doUpdate = false;
			
			
		}
		
		
		public function remove(swipeSeq:SwipeSequence):void {
			
			var bees:Vector.<int> = new Vector.<int>();
			
			for(var i:int=0; i<width*height; i++) {
				var gt:GameTile = gameTiles[i];
				if(gt && gt.getTile().type == GameLogic.BEE) {
					bees.push(i);
				}
			}
						
			
			for each(var i:int in swipeSeq.getIndexes()) {
								
				if(gameTiles[i]) {
					
					var tp:int = gameTiles[i].getTile().type;

					var x:int = (i % width) * tileSize;
					var y:int = (i / width) * tileSize;

					var effect:MovieClip = new effect_1();
					effect.x = x;
					effect.y = y;
					effect.play();
					parent.addChild(effect);
					
					if(tp >= GameLogic.HONEY0 && tp <= GameLogic.HONEY2) {

						var tx:int = 1000;
						var ty:int = 150;
						
						if(bees.length) {
							var j:int = bees.pop();
							tx = (j % width) * tileSize;
							ty = (j / width) * tileSize;						
						}
						
						
						//gameTiles[i].remove();
						gameTiles[i].moveTo(tx-x, ty-y,true);
						//gameTiles[i].fadeTo(0);
						gameTiles[i].remove();
						//gameTiles[i] = null;
					} else {
						gameTiles[i].remove();
					}
				}
			}
			doUpdate = true;
		}
		
		public function fall():void {
			trace("## FALLING");
			//return;
			for(var x:int=0; x<width; x++) {
				for(var y:int=height-1; y>=0; y--) {					
					//var t:GameTile = gameTiles[x+y*width];
					var yy:int = y;
					while(yy < height-1 && gameTiles[x+(yy)*width] && !gameTiles[x+(yy+1)*width]) {
						gameTiles[x+(yy)*width].fall(tileSize);
						gameTiles[x+(yy+1)*width] = gameTiles[x+(yy)*width];
						gameTiles[x+(yy)*width] = null;
						yy++;
					}							
				}
			}
			doUpdate = true;
		}
		
		
		public function rise():void {
			trace("## RISING");
			//return;
			for(var x:int=0; x<width; x++) {
				for(var y:int=0; y<height-1; y++) {					
					//var t:GameTile = gameTiles[x+y*width];
					var yy:int = y;
					while(yy >= 0 && gameTiles[x+(yy+1)*width] && !gameTiles[x+(yy)*width]) {
						gameTiles[x+(yy+1)*width].fall(-tileSize);
						gameTiles[x+(yy)*width] = gameTiles[x+(yy+1)*width];
						gameTiles[x+(yy+1)*width] = null;
						yy--;
					}							
				}
			}
			doUpdate = true;
		}
		
		public function fill(fromBottom:Boolean):void
		{
			for(var x:int=0; x<width; x++) {
				for(var y:int=height-1; y>=0; y--) {
					var i:int = x+ y*width;
					if(!gameTiles[i]) {
						var r:int;
						if(fromBottom)
							r= (Math.random() * tiles.length);
						else
							r = (Math.random() * 3);
						gameTiles[i] = new GameTile(tiles[r]);
						if(fromBottom)
							gameTiles[i].rise(40*y + 40);
						else
							gameTiles[i].fall(40*y + 40);
					}
				}
			}
			doUpdate = true;
		}
		
		public function countTiles(type:int):int
		{
			var count:int = 0;
			for(var i:int=0; i<width*height; i++) {
				if(gameTiles[i] && gameTiles[i].getTile().type == type) {
					count++;
				}
			}
			return count;
		}
		
		public function drawLine(swipeSeq:SwipeSequence, effects:MovieClip):void {
			// Remove all lines
			lineTiles = new Vector.<LineTile>(width * height);				
			while(lineContainer.numChildren) {
				lineContainer.removeChildAt(0);
			}

			// And draw new
			var seq:Vector.<int> = swipeSeq.getIndexes()
			for(var x:int=0; x<seq.length; x++) {
				var tileNo:int = seq[x];
				var position:Point = getPosition(tileNo);
				var nextPosition:Point = null;

				// Adding tile marked effect
				var effect:MovieClip = new plate_effect_2();
				effect.x = position.x * tileSize + (tileSize/2);
				effect.y = position.y * tileSize + (tileSize/2);
				effect.scaleX = 0.7;
				effect.scaleY = 0.7;
				effect.play();
				effects.addChild(effect);				
				
				var next:int = x + 1;
				if (next < seq.length) {
					var nextLineNo:int = seq[next];
					nextPosition = getPosition(nextLineNo);		
					var sp:Sprite = new Sprite;
					lineContainer.addChild(sp);
					sp.graphics.moveTo(position.x * tileSize + (tileSize/2), position.y * tileSize + (tileSize/2));
					sp.graphics.lineStyle(5, 0xffffff);
					sp.graphics.lineTo(nextPosition.x * tileSize + (tileSize/2), nextPosition.y * tileSize + (tileSize/2));
					
					var dropShadow:DropShadowFilter = new DropShadowFilter();
					dropShadow.color = 0x000000;
					dropShadow.blurX = 10;
					dropShadow.blurY = 10;
					dropShadow.angle = 0;
					dropShadow.alpha = 0.5;
					dropShadow.distance = 10;
					
					var filtersArray:Array = new Array(dropShadow);
					sp.filters = filtersArray;				
				}
				
				var direction = getDirection(position, nextPosition);
			}
			
			doUpdate = swipeSeq.length() > 0;
		}
		
		public function getDirection(position:Point, nextPosition:Point):String {
			if (nextPosition == null) {
				return LineDirection.NONE;
			}
			
			// South
			if (position.y < nextPosition.y) {
				if (position.x < nextPosition.x) {
					return LineDirection.SOUTH_EAST;
				}
				if (position.x > nextPosition.x) {
					return LineDirection.SOUTH_WEST;
				}				
				return LineDirection.SOUTH;
			}
			
			// North
			if (position.y > nextPosition.y) {
				if (position.x < nextPosition.x) {
					return LineDirection.NORTH_EAST;
				}
				if (position.x > nextPosition.x) {
					return LineDirection.NORTH_WEST;
				}								
				return LineDirection.NORTH;
			}
			
			// West or East of current position
			if (position.x < nextPosition.x) {
				return LineDirection.EAST;
			}
			if (position.x > nextPosition.x) {
				return LineDirection.WEST;
			}
			
			// Necessary?
			return LineDirection.NONE;
		}
		
		public function getPosition(tileNo:int):Point {


			
			return dict[tileNo];
		}
	}
}