package  
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author myachin
	 */
	public class Fader extends Sprite
	{
		public var color:uint = 0;
		public var _amount:Number = 0;
		
		public function Fader( color:uint, text:String = "" ) 
		{
			this.color = color;
			graphics.clear();
			graphics.beginFill(color);
			graphics.drawRect(0, 0, 200, 30);
			graphics.drawRect(4, 4, 200-8, 30-8);
			graphics.endFill();
		}
		
		
		public function set amount(value:Number):void 
		{
			_amount = value;
			graphics.clear();
			graphics.beginFill(color);
			graphics.drawRect(0, 0, 200, 30);
			graphics.drawRect(4, 4, 200-8, 30-8);
			graphics.endFill();
			
			graphics.beginFill(color);
			graphics.drawRect(6, 6, (200-12)*value , 30-12);
			graphics.endFill();
		}
		
		public function get amount():Number { return _amount; }
	}

}