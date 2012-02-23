package {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.filters.DisplacementMapFilterMode;

	public class GameBoard {
		
		private var width:int;
		private var height:int;
		private var tiles:Array;
		
		private var gameTiles:Vector.<GameTile>;
		
		public function GameBoard(w:int, h:int, tiles:Array) {
			width = w;
			height = h;
			this.tiles = tiles;
			
			gameTiles = new Vector.<GameTile>(w*h);
			for(var i:int=0; i<w*h; i++) {				
				var r:int = (Math.random() * tiles.length);				
				gameTiles[i] = new GameTile(tiles[r]);
			}
		}
		
		public function addChildren(parent:DisplayObjectContainer):void {
			
			for(var y:int=0; y<height; y++) {
				for(var x:int=0; x<width; x++) {
					var dob:DisplayObject = gameTiles[y*width+x].getDisplayObject();
					dob.x = x*40;
					dob.y = y*40;
					parent.addChild(dob);
				}
			}
			
			
		}
		
		
	}
}