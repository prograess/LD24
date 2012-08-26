package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.*;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.*;
	
	import com.adobe.serialization.json.JSON;
	import com.prograess.obvyazka.events.JSONEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class GameSprite extends Sprite 
	{
		public var playerX:Number = 400;
		public var playerY:Number = 300;
		public var terrain:Terrain;
		public var camera:Sprite;
		public var moveUp:Boolean = false;
		public var moveDown:Boolean = false;
		public var moveRight:Boolean = false;
		public var moveLeft:Boolean = false;
		public var step:int = 2;
		
		public static var me:Human;
		
		public function GameSprite() 
		{
			
			terrain = new Terrain();
			camera = new Sprite();		
			camera.addChild(terrain);
			camera.addChild(Bullet.bulletLayer);
			addChild(camera);
			
			
			
			camera.addChild(STATIC.units);	
			
			addEventListener (Event.ADDED_TO_STAGE, onStage);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			//Start event listeners
			STATIC.sc = new ServerController();
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
			var ang:int = Math.ceil(Math.atan2( e.stageY - playerY, e.stageX - playerX) / Math.PI * 180 );
			var bull:Bullet = new Bullet(me.x, me.y, ang);
			bull.shoot();
			
			var obj:Object = new Object;
			obj.x = bull.x;
			obj.y = bull.y;
			obj.rot = ang;
			STATIC.socket.sendJ("shoot",obj);
		}
		
		public function onMouseMove(e:MouseEvent):void
		{					
			if (STATIC.playerID == '-1') return;
			STATIC.getPlayerModel().pos.rot = Math.ceil( Math.atan2( e.stageY - playerY, e.stageX - playerX) / Math.PI * 180 );
			STATIC.units.renewUnit(STATIC.playerID);
		}
		
		public function onEnterFrame(e:Event = null):void 
		{
			if (STATIC.playerID != '-1') {
				camera.x = - STATIC.getPlayerModel().pos.x + 400;
				camera.y = - STATIC.getPlayerModel().pos.y + 300;
			}
			
			var newx:int;
			var newy:int;
			newx = newy = 0;
			if (STATIC.playerID != "-1") {
				newx = STATIC.getPlayerModel().pos.x;
				newy = STATIC.getPlayerModel().pos.y;
			}
			
			if (moveDown)
			{
				//camera.y -= step;
				newy += step;
			}
			if (moveUp)
			{
				//camera.y += step;
				newy -= step;
			}
			if (moveLeft)
			{
				//camera.x += step;
				newx -= step;
			}
			if (moveRight)
			{
				//camera.x -= step;
				newx += step;
			}
			if (STATIC.playerID != "-1") {
				STATIC.getPlayerModel().pos.x = newx;
				STATIC.getPlayerModel().pos.y = newy;
				STATIC.units.renewUnit(STATIC.playerID);
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