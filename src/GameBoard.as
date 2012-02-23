package {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.filters.DisplacementMapFilterMode;

	public class GameBoard {
		
		private var width:int;
		private var height:int;
		private var tiles:Array;
		private var parent:DisplayObjectContainer;
		private var doUpdate:Boolean;
		private var gameTiles:Vector.<GameTile>;
		
		public function GameBoard(parent:DisplayObjectContainer, w:int, h:int, tiles:Array) {
			width = w;
			height = h;
			this.tiles = tiles;
			this.parent = parent;
			
			gameTiles = new Vector.<GameTile>(w*h);
			for(var i:int=0; i<w*h; i++) {				
				var r:int = (Math.random() * tiles.length);				
				gameTiles[i] = new GameTile(tiles[r]);
			}
		}
		
		public function isMoving():Boolean {
			for(var i:int=0; i<width*height; i++) {
				if(gameTiles[i] && gameTiles[i].moving)
					return true;
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
							gameTiles[y*width+x].update(parent, x*40, y*40);
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
			for each(var i:int in swipeSeq.getIndexes()) {
				if(gameTiles[i]) {
					gameTiles[i].remove();
					//gameTiles[i] = null;
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
						gameTiles[x+(yy)*width].fall(40);
						gameTiles[x+(yy+1)*width] = gameTiles[x+(yy)*width];
						gameTiles[x+(yy)*width] = null;
						yy++;
					}							
				}
			}
			doUpdate = true;
		}
		
		public function fill():void
		{
			for(var x:int=0; x<width; x++) {
				for(var y:int=height-1; y>=0; y--) {
					var i:int = x+ y*width;
					if(!gameTiles[i]) {
						var r:int = (Math.random() * tiles.length);				
						gameTiles[i] = new GameTile(tiles[r]);
						gameTiles[i].fall(40*y + 40);
					}
				}
			}
			doUpdate = true;
		}
	}
}