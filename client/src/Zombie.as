package  
{
	import com.greensock.plugins.BlurFilterPlugin;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.WeakFunctionClosure;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.filters.GradientGlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author ...
	 */
	public class Zombie extends UnitSprite
	{
		public var zombie:Sprite;
		public var outfit:int = 0;
		
		public var tailx:Array = new Array;
		public var taily:Array = new Array;		
		public var tailxs:Array = new Array;
		public var tailys:Array = new Array;		

		public static var bloodcolors:Array = 
		[
			0x660000,
			0xf5fff3, 0xcc544e,	0x8c8ecf,
			0xe5d203, 0x30da6c,	0x99af05,
			0x6dd5d1, 0xe47b00,	0xefe58f,
			0xd786d2, 0x4dacfd,	0xcccccc,
			0xfe8b68, 0x3e9200,	0x8f7070
		];		
		
		public static var colors:Array = 
		[
			0x666666,
			0xf5fff3, 0xcc544e,	0x8c8ecf,
			0xe5d203, 0x30da6c,	0x99af05,
			0x6dd5d1, 0xe47b00,	0xefe58f,
			0xd786d2, 0x4dacfd,	0xcccccc,
			0xfe8b68, 0x3e9200,	0x8f7070
		];

		public static var eyecolors:Array = 
		[
			0x444444,
			0xf5fff3, 0xcc544e,	0x8c8ecf,
			0xe5d203, 0x30da6c,	0x99af05,
			0x6dd5d1, 0xe47b00,	0xefe58f,
			0xd786d2, 0x4dacfd,	0xcccccc,
			0xfe8b68, 0x3e9200,	0x8f7070
		];		
		
		public static var black_colors:Array = 
		[
			0x000000,
			0xff0000, 0x00ff00,	0x0000ff,
			0x440011, 0x004411,	0x110044,
			0x251203, 0x202a0c,	0x292f05,
			0x6d0541, 0x540b00,	0x0f058f,
			0x078642, 0x4d0c0d,	0xaf0c0c,
			0x0e1b68, 0x3e2200,	0x7f0010
		];		
		
		public var tailNum:int = 0;
		public var tailSegments:int = 0;
		
		public var tailSprite:Sprite = new Sprite;
		
		public function Zombie( gene:uint = 0, id:String = ""):void
		{
			var tf:TextField = new TextField;
			var ttf:TextFormat = new TextFormat("Arial", 7, 0xffffff);
			
			tf.defaultTextFormat = ttf;
			tf.text = id;
			tf.y = -20;
			tf.mouseEnabled = false;
			tailSprite.addChild( tf );
			outfit = gene;
			
			
			
			tailNum 		= 2 + ((outfit & 0x00003000) >> 12);
			tailSegments 	= 1 + ((outfit & 0x0000c000) >> 14);
			
			trace( tailNum + " " + tailSegments + " " + outfit.toString(16));
			
			for (var i:int = 0; i < tailNum * tailSegments; i++) 
			{
				tailx[i] = x;
				taily[i] = y;
				tailxs[i] = x;
				tailys[i] = y;
			}			
			
			
			drawZombie();
			speed = 0.9;
			
			addEventListener(Event.ENTER_FRAME, tailUpdate);
		}	
		public function drawZombie ():void
		{			
			zombie = new Sprite;
			zombie.graphics.beginFill( colors[(outfit & 0x000000f0) >> 4] , 1);
			zombie.graphics.lineStyle (0, 0x000000, 1);
			zombie.graphics.moveTo (0, -15);
			zombie.graphics.lineTo(-10, 0);
			zombie.graphics.lineTo(0, 15);
			zombie.graphics.lineTo(10, 0);		
			
			
			zombie.graphics.beginFill( colors[outfit & 0x0000000f] , 1);
			zombie.graphics.drawCircle(0,0, 9);
			zombie.graphics.endFill();
			
			zombie.graphics.lineStyle(2, eyecolors[(outfit & 0x000f0000) >> 16]);
			zombie.graphics.moveTo(6, 3);
			zombie.graphics.lineTo(10, 3);
			zombie.graphics.moveTo(6, -3);
			zombie.graphics.lineTo(10, -3);			
			
			zombie.graphics.lineStyle(0, black_colors[(outfit & 0x00000f00) >> 8] );
			zombie.graphics.moveTo(0, 15);
			zombie.graphics.lineTo(8, 8 + ((outfit & 0x00000f00) >> 8) );			
			zombie.graphics.moveTo(0, -15);
			zombie.graphics.lineTo(8, -8 - ((outfit & 0x00000f00) >> 8));						
			//this.filters = [new BlurFilter(2,2)];
			this.addChild(zombie);	
			addChild(tailSprite);
		}
		
		public function hideTail():void
		{
			for (var i:int = 0; i < tailNum * tailSegments; i++) 
			{
				tailx[i] = x;
				taily[i] = y;
				tailxs[i] = x;
				tailys[i] = y;
			}
		}
		

		
		public function tailUpdate( e:Event = null ):void
		{
			tailSprite.rotation = -rotation;
			
			// делаем зависимость от расстояния:
			var R:Number = (tailxs[tailSegments*(tailNum-1)] - x) * (tailxs[tailSegments*(tailNum-1)] - x) + (tailys[tailSegments*(tailNum-1)] - y) * (tailys[tailSegments*(tailNum-1)] - y);			
			
			if (R > 5000) hideTail();
			
			var p:Number = 0.6;// 0.35 + 800 / (2000 + R);
			var q:Number = 1 - p;			
			
			tailSprite.graphics.clear();
			
			// tailing
			for (var i:int = 0; i < tailNum*tailSegments; i++) 
			{
				tailx[i] += 8*(Math.random() - 0.5);
				taily[i] += 8*(Math.random() - 0.5);
			
				
				
			// attraction:
				if (i < tailNum)
				{
					var ang:Number = Math.PI*(-rotation + 25 * i * (i % 2 - 0.5) )/180.0;					
					tailx[i] = p * tailx[i] + q * (x - 9*Math.cos(ang) );
					taily[i] = p * taily[i] + q * (y + 9*Math.sin(ang) );
				}
				else 
				{
					tailx[i] = p * tailx[i] + q * tailx[i-tailNum];
					taily[i] = p * taily[i] + q * taily[i-tailNum];					
				}
				
				tailxs[i] = p * tailxs[i] + q * tailx[i];
				tailys[i] = p * tailys[i] + q * taily[i];
			}
			
			tailSprite.graphics.lineStyle( 1, black_colors[(outfit & 0x000f0000) >> 16] );
			
			for (var j:int = 0; j < tailNum; j++) 
			{
				//if (tailColor == 0x000000)
				//graphics.lineStyle(1, rainbow[j], 0.9);
				
				ang = Math.PI*(-rotation + 25 * j * (j % 2 - 0.5) )/180.0;					
				tailSprite.graphics.moveTo( - 9*Math.cos(ang) , + 9*Math.sin(ang) );
				
				for (var k:int = 0; k < tailSegments; k++) 
				{
					tailSprite.graphics.lineTo(tailxs[j + k*tailNum ]  - x, tailys[j + k*tailNum ] - y );		
				}
			}			
		}
	}

}