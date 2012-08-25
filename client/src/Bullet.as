package  
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author ...
	 */
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import flash.filters.DropShadowFilter;
	public class Bullet extends Sprite
	{
		public static const BulletTime:Number = 0.3;
		public static const BulletSpeed:Number = 10;
		public var bulletAngle:Number = 45 * Math.PI / 180;
		//public var bulletX:Number = 0;
		//public var bulletY:Number = 0;
		public var bullet:Sprite;
		public function Bullet(angle:Number):void
		{
			bulletAngle = angle * Math.PI / 180;
			drawBullet(0, 0);
		}
		
		public function drawBullet(x:int, y:int):void
		{	
			bullet = new Sprite;			
			bullet.graphics.lineStyle (1, 0xffd700);
			bullet.graphics.moveTo(x, y);
			bullet.graphics.lineTo (x + 500 * Math.cos(bulletAngle), y + 500 * Math.sin(bulletAngle));
			bullet.filters = [ new DropShadowFilter(0, bulletAngle / Math.PI * 180, 0xffd700, 1, 7, 7, 3)];
			this.addChild(bullet);			
			TweenMax.to (bullet, BulletTime, {
					dropShadowFilter:{color:0xffd700, alpha:0.3, blurX:0, blurY:0, distance:0, strength:0.5},
					onComplete: function():void {				
						
					}
				});
		}
		
		/*public function drawBullet():void
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
			
		}*/
	}

}