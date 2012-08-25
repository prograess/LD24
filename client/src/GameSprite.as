package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class GameSprite extends Sprite 
	{
		public var terrain:Terrain;
		public var camera:Sprite;
		public function GameSprite() 
		{
			terrain = new Terrain();
			camera = new Sprite();
			
			camera.addChild(terrain);
			addChild(camera);
						
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function onEnterFrame(e:Event):void {
			
		}
		
	}

}