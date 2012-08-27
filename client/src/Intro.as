package  
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.*;
	/**
	 * ...
	 * @author myachin
	 */
	public class Intro extends Sprite
	{
		[Embed(source = 'start.png')]
		public static var _startClass:Class;		
		public static var _start:Bitmap = new _startClass as Bitmap;
		
		[Embed(source = 'intro.png')]
		public static var _introClass:Class;		
		public static var _intro:Bitmap = new _introClass as Bitmap;
		
		public static var THIS:Intro = null;
		public function Intro() 
		{
			THIS = this;
			Main.THIS.removeChild(AskNameSprite.THIS);
			
			var crowSpr:Sprite = new Sprite;
			
			var crow:Zombie = new Zombie( 0x12345678, "");
			
			crowSpr.x = 630;
			crowSpr.y = 180;
			
			crow.scaleX = 4;
			crow.scaleY = 4;
			
			crowSpr.addChild( crow );
			addChild(crowSpr);
			
			addChild(_intro);
			
			var okBtn:ButtonSprite = new ButtonSprite();
			okBtn.x = 300;
			okBtn.y = 410;
			//okBtn.graphics.lineStyle(2, 0x888888);
			//okBtn.graphics.beginFill(0x888888);
			//okBtn.graphics.drawRect(0, 0, 50, 30);
			
			okBtn.addChild( _start );
			
			okBtn.addEventListener(MouseEvent.CLICK, function():void {
				
					STATIC.socket.sendJ("name", AskNameSprite.nameTF.text);
					ServerController.startPlay = getTimer();
					

			});
			
			addChild( okBtn );
			
			addEventListener(Event.ENTER_FRAME, 
				function():void
				{
					crow.update();
					Intro._intro.y = AskNameSprite.THIS.random(0,5);
					Intro._start.y = AskNameSprite.THIS.random(0, 5);
					crow.y = AskNameSprite.THIS.random(0, 5);
				});
		}
		
	}

}