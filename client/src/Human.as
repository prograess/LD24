package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	import flash.display.Bitmap;
	import flash.text.TextFormat;
	import flash.text.TextField;
	public class Human extends UnitSprite
	{
		public var human:Sprite;
		public static var a:Number = 40;
		public var b:Number = 10;
		public var c:Number = -10;
		
		[Embed(source = 'i.png')]
		public static var _iClass:Class;		
		public static var _i:Bitmap = new _iClass as Bitmap;
		
		public var tf:TextField;
		
		public function Human( str:String = ""):void
		{
			tf = new TextField;
			var ttf:TextFormat = new TextFormat("Arial", 7, 0xffffff);
			
			tf.defaultTextFormat = ttf;
			tf.text = str;
			tf.y = -30;
			tf.mouseEnabled = false;
			
			
			
			drawHuman();
			addChild(tf);
			addEventListener(Event.ENTER_FRAME, onFrame2);
		}	
		
		public function onFrame2 (e:Event = null) : void
		{
			tf.rotation = - rotation;
		}
		public function drawHuman ():void
		{			
			var bmp:Bitmap = new _iClass as Bitmap;
			
			bmp.x -= 32;
			bmp.y -= 32;
			addChild(bmp);
			
			human = new Sprite;
			human.graphics.beginFill(0x50ff50, 1);
			human.graphics.lineStyle (2, 0x888888, 1);
			human.graphics.moveTo (a, 0);
			human.graphics.lineTo(c, b);
			human.graphics.lineTo( c, -b);
			human.graphics.lineTo(a, 0);		
			human.graphics.endFill();
			//this.addChild(human);
		}
	}

}