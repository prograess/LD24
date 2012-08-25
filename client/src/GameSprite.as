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
		public var bullArray:Array = [];
		public var playerX:Number = 400;
		public var playerY:Number = 300;
		public var terrain:Terrain;
		public var camera:Sprite;
		public var humanLayer:Sprite = new Sprite;
		public var bulletLayer:Sprite = new Sprite;
		public var moveUp:Boolean = false;
		public var moveDown:Boolean = false;
		public var moveRight:Boolean = false;
		public var moveLeft:Boolean = false;
		public var player:Human = new Human;
		public var step:int = 2;
		public function GameSprite() 
		{
			
			terrain = new Terrain();
			camera = new Sprite();		
			camera.addChild(terrain);
			addChild(camera);
			
			humanLayer.x = playerX;
			humanLayer.y = playerY;
			addChild(humanLayer);
			addChild(bulletLayer);
			
			humanLayer.addChild(player);		
			
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
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		public function onMouseDown(e:MouseEvent):void
		{		

			var bull:Bullet = new Bullet(Math.atan2( e.stageY - playerY, e.stageX - playerX));
			bull.x = playerX;
			bull.y = playerY;
			bulletLayer.addChild(bull);	
			bullArray.push(bull);
			
		}
		
		public function onMouseMove(e:MouseEvent):void
		{					
			player.rotation = Math.atan2( e.stageY - playerY, e.stageX - playerX) / Math.PI * 180;			

		}
		
		public function onEnterFrame(e:Event = null):void 
		{
			if (moveDown)
			{
				camera.y-=step;
			}
			if (moveUp)
			{
				camera.y+=step;
			}
			if (moveLeft)
			{
				camera.x+=step;
			}
			if (moveRight)
			{
				camera.x-=step;
			}
			for (var i:uint = 0; i < bullArray.length; ++i)
			{
				bullArray[i].drawBullet();
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