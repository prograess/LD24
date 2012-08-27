package  
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author myachin
	 */
	public class BloodRain extends Sprite
	{
		public var bloodDrops:Array = [];
		public var bloods:Array = [];
		
		public var spots:int = 20;
		
		public function BloodRain(x:int, y:int, color:uint = 0xff0000, spots:int = 4) 
		{
			this.x = x;
			this.y = y;
			this.spots = spots
			
			if ( maxBlood > 30 ) return;
			
			for (var i:int = 0; i < spots; i++) 
			{
				var blood:Shape = new Shape;
				
				for (var j:int = 0; j < 3; j++) 
				{
					blood.graphics.beginFill( color );
					blood.graphics.drawCircle( 15 * (Math.random() - 0.5), 15 * (Math.random() - 0.5), 1 + 10 * Math.random() );
					blood.graphics.endFill();
				}
				
				bloodDrops.push(blood);
				bloods.push( { dx:10*(Math.random()-0.5), dy:10*(Math.random()-0.5), dr:(Math.random() - 0.5) * 200 } );
				
				addChild(blood);
			}
			
			addEventListener(Event.ENTER_FRAME, anim);
			
			maxBlood++;
		}
		
		public var frames:int = 0;
		
		public static var maxBlood:int = 0;
		
		public function anim (e:Event = null) : void
		{
			frames ++;
			
			for (var i:int = 0; i < spots; i++) 
			{
				var b:Shape = bloodDrops[i] as Shape;
				var bb:Object = bloods[i];
				
				b.x += bb.dx;
				b.y += bb.dy;
				b.rotation += bb.dr;
				
				bb.dx *= 0.9;
				bb.dy *= 0.9;
				bb.dr *= 0.9;
			}
			
			alpha *= 0.9;
			
			if (frames > 20)
			{
				removeEventListener(Event.ENTER_FRAME, anim);
				while (numChildren) removeChildAt(0);
				parent.removeChild( this );
				maxBlood--;
			}
		}
	}

}