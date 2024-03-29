package {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.DisplacementMapFilterMode;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
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
		private var filtersArray:Array;		
		private var scoreX:int;
		private var scoreY:int;
		
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
			if(i<0 || i > gameTiles.length) return null;
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
			
			for(var y:int=0; y<height; y++) {
				for(var x:int=0; x<width; x++) {
					dict[counter] = new Point(x * tileSize + (tileSize/2), y * tileSize + (tileSize/2));
					counter++;
				}
			}
			
			// Filters for line
			var dropShadow:DropShadowFilter = new DropShadowFilter();
			dropShadow.color = 0x000000;
			dropShadow.blurX = 10;
			dropShadow.blurY = 10;
			dropShadow.angle = 0;
			dropShadow.alpha = 0.5;
			dropShadow.distance = 10;
			filtersArray = new Array(dropShadow);
			// color, alpha (transparency), blurX, blurY, strength (intensity), quality (low, med, high), inner knock out
			var glowFilter:GlowFilter = new GlowFilter(0xFF6699, .75, 5, 5, 2, 2, false, false);
			filtersArray.push(glowFilter);
		}
		
		public function isMoving():Boolean {
			for(var i:int=0; i<width*height; i++) {
				if(gameTiles[i] && gameTiles[i].moving > 0) {
//					/trace("Tile ",i,"is moving", gameTiles[i].moving);
					return true;
				}
			}
			return false;
		}
		
		public function update(full:Boolean= false):void {
			
			if(!doUpdate && !full) {
				if(!isMoving()) return;
			}
			
			//trace("## UPDATE");
			
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
		
		public function setHoneyTarget(x:int, y:int) {
			scoreX = x;
			scoreY = y;
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

					/*var effect:MovieClip = new small_EFFECT();
					effect.x = x;
					effect.y = y;
					effect.play();
					parent.addChild(effect);*/
					
					if(tp >= GameLogic.HONEY0 && tp <= GameLogic.HONEY2) {

						var tx:int = scoreX;
						var ty:int = scoreY;
						
						if(bees.length) {
							var j:int = bees.pop();
							tx = (j % width) * tileSize;
							ty = (j / width) * tileSize;// + tileSize/2;
						}
						tx += (tileSize/2);
						ty += (tileSize/2);
												
						//gameTiles[i].remove();
						gameTiles[i].fadeTo(0);
						gameTiles[i].moveTo(tx-x, ty-y,true);
						//gameTiles[i].remove();
						//gameTiles[i] = null;
					} else {
						
						var cx:int = tileSize * width / 2;
						var cy:int = tileSize * height / 2;
						
						var angle:Number = Math.random() * 2 * Math.PI;
						var ax:Number = cx + Math.cos(angle) * tileSize * width; 
						var ay:Number = cy + Math.sin(angle) * tileSize * height;
						
						gameTiles[i].moveTo(ax-x, ay-y,true);
						
						//gameTiles[i].remove();
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
						gameTiles[i].dy = 0;
						if(fromBottom) {
							gameTiles[i].rise(tileSize*y + tileSize);
						} else {
							gameTiles[i].fall(tileSize*y + tileSize);
						}
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
		
		public function countHoney():int {
			var count:int = 0;
			for(var i:int=0; i<width*height; i++) {
				if(gameTiles[i] && gameTiles[i].getTile().type <= GameLogic.HONEY2) {
					count++;
				}
			}
			return count;
		}

		
		public function drawLine(swipeSeq:SwipeSequence, effects:MovieClip, size:int = 5):void {
			// Remove all lines
			//return;
			lineTiles = new Vector.<LineTile>(width * height);				
			while(lineContainer.numChildren) {
				lineContainer.removeChildAt(0);
			}

			//while(effects.numChildren)
			//	effects.removeChildAt(0);
			
			//trace("%%%%", effects.numChildren);

			// And draw new
			var sprite:Sprite = new Sprite;
			sprite.graphics.lineStyle(size, 0xffffff);
			sprite.filters = filtersArray;
			lineContainer.addChild(sprite);

			var points:Vector.<Point> = new Vector.<Point>;
			for each (var tileNo:int in swipeSeq.getIndexes()) {
				points.push(getPosition(tileNo));
			}

			drawRoundPath(sprite, points);
			doUpdate = swipeSeq.length() > 0;
		}
		
		public function drawRoundPath(g:Sprite, points:Vector.<Point>, radius:Number = 20):void {  
			var count:int = points.length;  
			if (count < 2) return;  
			
			var p0:Point = points[0];  
			var p1:Point = points[1];  
			var p2:Point;  
			var pp0:Point;  
			var pp2:Point;  
			
			var last:Point;  

			g.graphics.moveTo(p0.x, p0.y);  
			last = points[count - 1];  
			
			var n:int = count - 1;  
			
			for (var i:int = 1; i < n; i++) {  
				p2 = points[(i + 1) % count];  
				
				var v0:Point = p0.subtract(p1);  
				var v2:Point = p2.subtract(p1);  
				var r:Number = Math.max(1, Math.min(radius,  
					Math.min(v0.length / 2, v2.length / 2)));  
				v0.normalize(r);  
				v2.normalize(r);  
				pp0 = p1.add(v0);  
				pp2 = p1.add(v2);  
				
				g.graphics.lineTo(pp0.x, pp0.y);
				g.graphics.curveTo(p1.x, p1.y, pp2.x, pp2.y);  
				p0 = p1;  
				p1 = p2;  
			}  
			
			g.graphics.lineTo(last.x, last.y);  
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