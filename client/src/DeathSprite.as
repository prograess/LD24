package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	import flash.display.Bitmap;
	
	/**
	 * ...
	 * @author myachin
	 */
	public class DeathSprite extends Sprite
	{
		public var tf:TextField;
		public static var THIS:DeathSprite = null;
		
		[Embed(source = 'continue.png')]
		public static var _continueClass:Class;		
		public static var _continue:Bitmap = new _continueClass as Bitmap;
		
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
			
			//buttonMode = true;
			
			visible = false;
			
			var c:ButtonSprite = new ButtonSprite;
			
			c.addEventListener(MouseEvent.CLICK, 
				function(e:Event):void
				{
					if (DeathSprite.THIS.visible)
					{
						parent.removeChild( THIS );
						ServerController.startPlay = getTimer();
						GameSprite.liveFader.amount = 1;
						GameSprite.staminaFader.amount = 1;
						STATIC.socket.sendJ("RE", { } );
						GameSprite.kills = 0;
						DeathSprite.THIS.visible = false;
						MusicMixer.playDefaultTrack();
					}
				});
				
			_continue.x = 400 - _continue.width / 2;
			_continue.y = 350;
				
			
			
			addChild(tf);
			c.addChild(_continue);
			
			var a:ButtonSprite = new ButtonSprite;
			
			a.useHandCursor = false;
			a.drawPad(0, 0, 800, 600);
			
			addChild(c);
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		public function show ( text:String):void
		{
			tf.text = text;
			DeathSprite.THIS.visible = true;
			MusicMixer.playClick4();
		}
		
		public function onFrame (e:Event = null) : void
		{
			graphics.clear();
			graphics.beginFill( Math.ceil( (0xff * Math.random()) << 16) & 0x008888 );
			graphics.drawRect(0, 0, 800, 600);
			
			_continue.y = 350 + AskNameSprite.THIS.random(0, 5);
			
			tf.y = 100 + AskNameSprite.THIS.random(0, 5);
		}
	}

}