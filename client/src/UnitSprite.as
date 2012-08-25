package  
{
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author ...
	 */
	public class UnitSprite extends Sprite
	{
		public var rx:int = 0;
		public var ry:int = 0;
		public var speed: Number = 0.8;
		
		public function UnitSprite() 
		{
			x = -1000;
			y = -1000;
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		public function onFrame(e:Event):void 
		{
			if ( (rx - x > 100) || (rx - x < -100) || (ry - y > 100) || (ry - y < -100) )
			{
				x = rx;
				y = ry;
			}
			else
			{
				x = speed * x + (1-speed) * rx;
				y = speed * y + (1-speed) * ry;
			}
		}
	}

}
