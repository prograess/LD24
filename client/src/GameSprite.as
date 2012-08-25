package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.*;
	import flash.ui.Keyboard;
	import com.adobe.serialization.json.JSON;
	import com.prograess.obvyazka.events.JSONEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class GameSprite extends Sprite 
	{
		public var terrain:Terrain;
		public var camera:Sprite;
		public var moveUp:Boolean = false;
		public var moveDown:Boolean = false;
		public var moveRight:Boolean = false;
		public var moveLeft:Boolean = false;
		public var step:int = 2;
		public function GameSprite() 
		{
			terrain = new Terrain();
			camera = new Sprite();
			
			camera.addChild(terrain);
			addChild(camera);
			addEventListener (Event.ADDED_TO_STAGE, onStage);
						
			addEventListener(Event.ENTER_FRAME, onEnterFrame);

			
			OBVYAZKA.socket.addEventListener("yourself", function(e:JSONEvent):void {
				trace("yourself: " + JSON.encode(e.data));
			});
			OBVYAZKA.socket.addEventListener("newunit", function(e:JSONEvent):void {
				trace("newunit: " + JSON.encode(e.data));
			});
			OBVYAZKA.socket.addEventListener("removeunit", function(e:JSONEvent):void {
				trace("removeunit: " + JSON.encode(e.data));
			});
			OBVYAZKA.socket.addEventListener("unitlist", function(e:JSONEvent):void {
				trace("unitlist: " + JSON.encode(e.data));
			});
		}
		
		public function onStage (e:Event):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);				
		}
		
		public function onEnterFrame(e:Event = null):void 
		{
			if (moveDown)
			{
				camera.y-=step;
			}
			else if (moveUp)
			{
				camera.y+=step;
			}
			else if (moveLeft)
			{
				camera.x+=step;
			}
			else if (moveRight)
			{
				camera.x-=step;
			}
		}
		
		public function onKeyUp (e:KeyboardEvent):void
		{
			
			switch (e.keyCode)
			{
				case Keyboard.UP:
					moveUp = false;
					break;
				case Keyboard.DOWN:
					moveDown = false;
					break;		
				case Keyboard.LEFT:
					moveLeft = false;
					break;
				case Keyboard.RIGHT:
					moveRight = false;
					break;
			}
		}
		
		public function onKeyDown(e:KeyboardEvent):void
		{		
			
			switch (e.keyCode)
			{
				case Keyboard.UP:
					moveUp = true;
					break;
				case Keyboard.DOWN:
					moveDown = true;
					break;		
				case Keyboard.LEFT:
					moveLeft = true;
					break;
				case Keyboard.RIGHT:
					moveRight = true;
					break;
			}
		}
		
	}

}