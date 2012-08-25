package  
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author myachin
	 */
	public class ButtonSprite extends Sprite
	{
		
		public function ButtonSprite() 
		{
			buttonMode = true;
			useHandCursor = true;
		}
		
		public function drawPad (_x:int, _y:int, _w:int, _h:int):void
		{
			graphics.beginFill(0, 0);
			graphics.drawRect(_x, _y, _w, _h);
			graphics.endFill();
		}
		
	}

}