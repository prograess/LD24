package  
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author 
	 */
	public class Terrain extends Sprite 
	{
		public var w:uint = 5000;
		public var h:uint = 3000;
		public function Terrain() 
		{			
		
			var i:uint = 0;
			var j:uint = 0;
			
			for (i = 0; i < 1000; i++ ) 
			{	
				drawCircle();
			}
		}
		
		public function drawCircle():void
		{
			var circleSprite:Sprite = new Sprite;
			circleSprite.graphics.beginFill(0xff0000, 1);
			circleSprite.graphics.drawCircle (Math.random() * w, Math.random() * h, 10);
			circleSprite.graphics.endFill();
			this.addChild(circleSprite);
		}
		
	}

}