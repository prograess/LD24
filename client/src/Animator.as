package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author myachin
	 */
	public class Animator extends Sprite
	{
		public var frames:Array = [];
		public var framePause:int = 1;
		public var currentFrame:int = 0;
		public var currentFramePause:int = 1;
		public var w:int = 16;
		public var h:int = 16;
		public var repeatFrame:int = 0;
		
		public var bmpData:BitmapData;
		public var bmp:Bitmap;
		public var source:Bitmap;
		
		public function Animator( tileSource:Bitmap, w:int = 16, h:int = 16 ) : void
		{
			this.w = w;
			this.h = h;
			
			source = tileSource;
			
			addEventListener(Event.ENTER_FRAME, onFrame);
			
			bmpData = new BitmapData(w, h, true, 0x00000000);
			bmp = new Bitmap(bmpData);
			
			addChild(bmp);
			
		}
		
		
		
		public function onFrame (e:Event = null) : void
		{
			if (currentFramePause != 1) currentFramePause--;
			else
			{
				currentFramePause = framePause;
				
				var frame:int = 0;
				
				if (frames.length != 0) 
				{
					currentFrame++;
					if (currentFrame > frames.length - 1)
						currentFrame = repeatFrame;
						
					frame = frames[currentFrame];
				}
				
				var w0:int = frame % (source.width/w);
				var h0:int = frame / (source.width/w);
				bmpData.copyPixels( source.bitmapData, new Rectangle( w0 * w, h0 * h, w, h), new Point(0, 0) );				
				bmp.bitmapData = bmpData;
			}
		}
	}

}