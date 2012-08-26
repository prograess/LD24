package  
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author myachin
	 */
	public class Spawn extends UnitSprite
	{
		
		public function Spawn() 
		{
			graphics.beginFill(0x00ff00, 1);
			graphics.drawCircle(0, 0, 5);
			graphics.drawCircle(0, 0, 7);
			graphics.drawCircle(0, 0, 9);
			graphics.drawCircle(0, 0, 11);
			graphics.drawCircle(0, 0, 2);
			graphics.drawCircle(0, 0, 3);
		}
		
	}

}