package  
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class Units extends Sprite
	{
		public static var unitModels:Array;
		public static var unitSprites:Array;
		public static var playerID:uint;
		
		public function Units() 
		{
		}
		
		public function addUnit():void
		{
			var newUnit:Sprite = new Sprite;
			newUnit.graphics.beginFill(0xf2e107);
			newUnit.graphics.drawRect(0, 0, 20, 20 );
			newUnit.graphics.endFill();
			this.addChild(newUnit);
		}
	}

}