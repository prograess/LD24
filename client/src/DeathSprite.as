package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author myachin
	 */
	public class DeathSprite extends Sprite
	{
		public var tf:TextField;
		public static var THIS:DeathSprite = null;
		
		public function DeathSprite() 
		{
			THIS = this;
			tf = new TextField;
			var ttf:TextFormat = new TextFormat("Arial", 47, 0xffffff);
			ttf.align = TextFormatAlign.CENTER;
			
			tf.defaultTextFormat = ttf;
			tf.text = "";
			tf.y = 100;
			tf.width = 800;
			tf.height = 600;
			tf.mouseEnabled = false;
			
			buttonMode = true;
			
			addEventListener(MouseEvent.CLICK, 
				function(e:Event):void
				{
					
					parent.removeChild( THIS );
					ServerController.startPlay = getTimer();
					STATIC.socket.sendJ("RE", {});
				});
			
			addChild(tf);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		public function show ( text:String):void
		{
			tf.text = text;
		}
		
		public function onFrame (e:Event = null) : void
		{
			graphics.clear();
			graphics.beginFill( Math.ceil(0xff * Math.random()) << 16 );
			graphics.drawRect(0,0,800,600);
		}
	}

}