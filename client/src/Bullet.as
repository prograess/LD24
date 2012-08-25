package  
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author ...
	 */
	public class Bullet extends Sprite
	{
		public static const BulletSpeed:Number = 10;
		public var bulletAngle:Number = 45 * Math.PI / 180;
		public var bulletX:Number = 0;
		public var bulletY:Number = 0;
		public var bullet:Sprite;
		public function Bullet(angle:Number):void
		{
			bulletAngle = angle;
			drawBullet();
		}
		
		public function drawBullet():void
		{
			while (this.numChildren)
				this.removeChildAt(0);				
				
			bullet = new Sprite;
			bullet.graphics.beginFill (0x000000, 1);
			bulletX += Math.cos(bulletAngle) * BulletSpeed;
			bulletY += Math.sin(bulletAngle) * BulletSpeed;
			bullet.graphics.drawCircle(bulletX , bulletY, 3);
			bullet.graphics.endFill();
			this.addChild(bullet);
			
		}
	}

}