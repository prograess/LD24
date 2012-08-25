package  
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author ...
	 */
	public class Human extends UnitSprite
	{
		public var human:Sprite;
		public var a:Number = 40;
		public var b:Number = 10;
		public var c:Number = -10;
		
		public function Human():void
		{
			drawHuman();
		}	
		public function drawHuman ():void
		{			
			human = new Sprite;
			human.graphics.beginFill(0x50ff50, 1);
			human.graphics.lineStyle (2, 0x888888, 1);
			human.graphics.moveTo (a, 0);
			human.graphics.lineTo(c, b);
			human.graphics.lineTo( c, -b);
			human.graphics.lineTo(a, 0);		
			human.graphics.endFill();
			this.addChild(human);
		}
	}

}