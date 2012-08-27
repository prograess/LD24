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
		
		[Embed(source = 'i2.png')]
		public static var _i2Class:Class;		
		public static var _i2:Bitmap = new _i2Class as Bitmap;
		
		[Embed(source = 'i3.png')]
		public static var _i3Class:Class;		
		public static var _i3:Bitmap = new _i3Class as Bitmap;
		
		[Embed(source = 'head.png')]
		public static var _headClass:Class;		
		public static var _head:Bitmap = new _headClass as Bitmap;
		
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
			
			b1.y = 0.8*b1.y + 0.2*-11;
			b3.x = 0.8*b3.x + 0.2*-32;
		}
		
		public var b1:Bitmap = new _headClass as Bitmap;
		public var b2:Bitmap = new _i2Class as Bitmap;
		public var b3:Bitmap = new _i3Class as Bitmap;
		
		public function drawHuman ():void
		{			
			b1.x = -11;
			b1.y = -11;
			b2.x -= 32;
			b2.y -= 32;
			b3.x -= 32;
			b3.y -= 32;
			
			addChild(b3);
			addChild(b2);
			addChild(b1);
			
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
		
		public function turbulum ():void
		{
			b1.y += Math.random() * 2 - 1;
			b3.x += Math.random() * 2 - 1;
		}
	}

}