package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.display.Bitmap;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author 
	 */
	public class AskNameSprite extends Sprite 
	{
		public var enterNameTF:TextField;
		public static var nameTF:TextField;
		public var okBtn:ButtonSprite;
		
		[Embed(source = 'logo.png')]
		public static var _logoClass:Class;		
		public static var _logo:Bitmap = new _logoClass as Bitmap;
		
		[Embed(source = 'button.png')]
		public static var _buttonClass:Class;		
		public static var _button:Bitmap = new _buttonClass as Bitmap;
		
		public static var THIS:AskNameSprite = null;
		
		public function AskNameSprite() 
		{
			THIS = this;
			enterNameTF = new TextField();
			enterNameTF.height = 30;
			enterNameTF.text = "enter your name";
			
			var ttf:TextFormat = new TextFormat("Arial", 34, 0xffffff, null, null, null, null, null, TextFormatAlign.CENTER);
			
			nameTF = new TextField();
			nameTF.x = 150;
			nameTF.y = 350;
			nameTF.type = TextFieldType.INPUT;
			nameTF.border = false;
			nameTF.borderColor = 0xff0000;
			nameTF.height = 50;
			nameTF.width = 500;
			nameTF.maxChars = 30;
			
			nameTF.defaultTextFormat = ttf;
			
			
			
			
			okBtn = new ButtonSprite();
			okBtn.x = 300;
			okBtn.y = 410;
			//okBtn.graphics.lineStyle(2, 0x888888);
			//okBtn.graphics.beginFill(0x888888);
			//okBtn.graphics.drawRect(0, 0, 50, 30);
			
			okBtn.addChild( _button );
			
			okBtn.addEventListener(MouseEvent.CLICK, function():void {
				if (nameTF.text != ""){
					Main.THIS.addChild( new Intro() );
				}
			});
			
			addChild(okBtn);
			addChild(nameTF);
			//addChild(enterNameTF);
			
			_logo.x = 400 - _logo.width / 2;
			addChild( _logo);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		public function onFrame (e:Event = null) : void
		{
			_logo.y = Math.random() *5;
			
			graphics.clear();
			graphics.lineStyle(2, 0xffffff);
			var sx:int = 150 + random(-10,10);
			var sy:int = 350 + random(-10,10);
			graphics.moveTo( sx,sy );
			graphics.lineTo( 650 + random(-10,10), 350 + random(-10,10) );
			graphics.lineTo( 650 + random(-10,10), 400 + random(-10,10) );
			graphics.lineTo( 150 + random( -10, 10), 400 + random( -10, 10) );
			graphics.lineTo( sx, sy );
			
			okBtn.y = 410 + Math.random() * 3;
		}
		
		
		public function random(a:Number, b:Number):Number
		{
			return (b - a) * Math.random() + a;
		}
	}

}