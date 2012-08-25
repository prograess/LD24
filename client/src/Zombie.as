package  
{
	import com.greensock.plugins.BlurFilterPlugin;
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.filters.GradientGlowFilter;
	/**
	 * ...
	 * @author ...
	 */
	public class Zombie extends UnitSprite
	{
		public var zombie:Sprite;
		
		public function Zombie():void
		{
			drawZombie();
			speed = 0.9;
		}	
		public function drawZombie ():void
		{			
			zombie = new Sprite;
			zombie.graphics.beginFill(0xff8888, 1);
			zombie.graphics.lineStyle (2, 0x000000, 1);
			zombie.graphics.moveTo (-10, -10);
			zombie.graphics.lineTo(-10, 10);
			zombie.graphics.lineTo(10, 10);
			zombie.graphics.lineTo(10, -10);		
			zombie.graphics.endFill();
			this.filters = [new BlurFilter(2,2)];
			this.addChild(zombie);
		}
	}

}