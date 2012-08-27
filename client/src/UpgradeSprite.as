package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import flash.text.*;
	/**
	 * ...
	 * @author myachin
	 */
	public class UpgradeSprite extends Sprite
	{
		public var tf:TextField = new TextField;
		
		public static var levels:Array = [
		"Crow Killer!", "Big Killer!", "Mega Killer!", "Super Killer!", "BATMAN!",
		"Hyper Killer!", "Ultimate Killer!", "Crowminator!", "Total Killer!", "Crow Genocide!",
		"Crowtastrofic killer!", "Crow Hitler!", "Super Murderer!", "Super Hitman!", "God of DNA",
		"Ultrasonic Killer!", "Bird Destroyer", "Total Demolition!", "Crowambo", "BATMAN AGAIN!",
		"Fantastic Killer!", "Fear of birds", "Crows nightmare", "Predator!", "BATMAN AGAIN 2!",
		"Please stop...","Please stop...","Please stop...","Please stop...","Please stop...","BATMAN AGAIN 3!",
		"Please stop...","Please stop...","Please stop...","Please stop...","Please stop...","BATMAN AGAIN 4!",
		"Please stop...","Please stop...","Please stop...","Please stop...","Please stop...","BATMAN AGAIN 5!",
		"Please stop...","Please stop...","Please stop...","Please stop...","Please stop...","BATMAN AGAIN 6!",
		"Please stop...","Please stop...","Please stop...","Please stop...","Please stop...","BATMAN AGAIN 7!"
		];
		
		public function UpgradeSprite( level:int ) 
		{
			
			var ttf:TextFormat = new TextFormat("Arial", 27, 0xffffff);
			ttf.align = TextFormatAlign.CENTER;
			tf.defaultTextFormat = ttf;
			tf.text = "Level "+ level.toString()+": " +levels[level];
			tf.y = 70;
			tf.width = 800;
			tf.mouseEnabled = false;
			addChild( tf );			
			
			
			addEventListener(Event.ENTER_FRAME, anim);
		}


		
		public var frames:int = 0;

		
		public function anim (e:Event = null) : void
		{
			frames ++;
			
			tf.y = 70 + AskNameSprite.THIS.random(0,5);

			if (frames > 90)
			{
				removeEventListener(Event.ENTER_FRAME, anim);
				while (numChildren) removeChildAt(0);
				parent.removeChild( this );
				
			}
		}
		
	}

}