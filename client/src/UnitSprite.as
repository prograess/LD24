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
		public var rrot:Number = 0;
		public var speed: Number = 0.9;
		
		public function UnitSprite() 
		{
			x = -1000;
			y = -1000;
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		public var unUpdated:int = 0;
		
		public function update ():void
		{
			unUpdated = 0;
			
			if (!visible) visible = true;
		}
		
		public static var THRESHOLD:int = 300;
		
		public function onFrame(e:Event):void 
		{
			unUpdated++;
			
			if (unUpdated > 180) 
				visible = false;
			
			if ( (rx - x > THRESHOLD) || (rx - x < -THRESHOLD) || (ry - y > THRESHOLD) || (ry - y < -THRESHOLD) )
			{
				x = rx;
				y = ry;
				rotation = rrot;
			}
			else
			{
				x = speed * x + (1-speed) * rx;
				y = speed * y + (1 - speed) * ry;
				
				if (rrot - rotation > 180) rrot -= 360;
				if (rrot - rotation < -180) rrot += 360;
				
				rotation = speed * rotation + (1 - speed) * rrot;
			}
			
		}
	}

}
