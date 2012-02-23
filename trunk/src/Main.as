package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class Main extends Sprite {
		public function Main() {
			
			var ball:MovieClip = new ballBlue();
			ball.x = 100;
			ball.y = 100;
			ball.stop();
			addChild(ball);
		}
	}
}