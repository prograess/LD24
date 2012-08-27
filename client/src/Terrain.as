package  
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	
	/**
	 * ...
	 * @author 
	 */
	public class Terrain extends Sprite 
	{
		public var w:uint = 5000;
		public var h:uint = 3000;
		
		[Embed(source = 'lava.png')]
		public static var _lavaClass:Class;		
		public static var _lava:Bitmap = new _lavaClass as Bitmap;
		
		public function Terrain() 
		{			
			graphics.beginBitmapFill(_lava.bitmapData);
			graphics.drawRect(-3600,-3600, 7200, 7200);					
			graphics.beginBitmapFill(GameSprite._back.bitmapData);
			graphics.drawRect(-3000,-3000, 6000, 6000);


			var i:uint = 0;
			var j:uint = 0;
			
			for (i = 0; i < 1000; i++ ) 
			{	
				//drawCircle();
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