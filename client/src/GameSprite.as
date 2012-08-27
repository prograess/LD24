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
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import com.adobe.serialization.json.JSON;
	import com.prograess.obvyazka.events.JSONEvent;
	
	import flash.display.Bitmap;
	
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
		
		public static var liveFader:Fader = new Fader( 0xff0000 );
		public static var staminaFader:Fader = new Fader( 0x00ff11 );
		
		public static var me:Human;
		
		[Embed(source = 'back.png')]
		public static var _backClass:Class;		
		public static var _back:Bitmap = new _backClass as Bitmap;
		
		public static var THIS:GameSprite = null;
		
		public static var death:DeathSprite = new DeathSprite;
		
		public function GameSprite() 
		{
			addChild(liveFader);
			addChild(staminaFader);
			
			THIS = this;
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
			
			liveFader.x = 20;
			liveFader.y = 20;
			liveFader.amount = 1;
			
			staminaFader.x = 240;
			staminaFader.y = 20;			
			staminaFader.amount = 1;
			
			addChild( liveFader );
			addChild( staminaFader );		
			
			
			
			var ttf:TextFormat = new TextFormat("Arial", 17, 0xffffff);
			
			tf.defaultTextFormat = ttf;
			tf.text = "Kills: 0\nTime: 0s";
			tf.x = 650;
			tf.y = 20;
			tf.mouseEnabled = false;
			addChild( tf );			
		}
		
		public static var kills:int = 0;
		
		public static var tf:TextField = new TextField;
		
		public function onStage (e:Event):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);	
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		public static var lastShotTime:int = 0;
		public static var SHOT_TIME:int = 200;
		
		public function onMouseDown(e:MouseEvent):void
		{		
			if (lastShotTime > getTimer() - SHOT_TIME ) 
			{
				return;
			}
			
			lastShotTime = getTimer();
			
			var ang:int = Math.ceil(Math.atan2( e.stageY - (camera.y + me.y), e.stageX - (camera.x + me.x)) / Math.PI * 180 );
			var bull:Bullet = new Bullet(me.x, me.y, ang);
			bull.shoot();
			
			var obj:Object = new Object;
			obj.x = bull.x;
			obj.y = bull.y;
			obj.rot = ang;
			obj.id = STATIC.playerID;
			STATIC.socket.sendJ("shoot",obj);
		}
		
		public function onMouseMove(e:MouseEvent):void
		{					
			if (STATIC.playerID == '-1') return;
			STATIC.getPlayerModel().pos.rot = Math.ceil( Math.atan2( e.stageY - playerY, e.stageX - playerX) / Math.PI * 180 );
			STATIC.getPlayerModel().pos.rot = Math.ceil( Math.atan2( e.stageY - playerY, e.stageX - playerX) / Math.PI * 180 );
			
			me.rotation = me.rrot;
			
			STATIC.units.renewUnit(STATIC.playerID);
		}
		
		public function onEnterFrame(e:Event = null):void 
		{
			tf.text = "Kills: "+kills+"\nTime: "+Math.floor((getTimer() - ServerController.startPlay)/1000).toString()+"s";
			
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
			
			var staminaBonus:Number = 1.0;
			var staminaTrata:Number = 0.002;

			if (staminaFader.amount > 0.5)
			{
				staminaBonus = 3.0;
			}			
			else if (staminaFader.amount > 0.05)
			{
				staminaBonus = 2.0;
			}
			
			var isStam: Boolean = false;
			
			if (moveDown)
			{
				//camera.y -= step;
				newy += staminaBonus * step;
				staminaFader.amount -= staminaTrata;
				isStam = true;
			}
			if (moveUp)
			{
				//camera.y += step;
				newy -= staminaBonus * step;
				staminaFader.amount -= staminaTrata;
				isStam = true;
			}
			if (moveLeft)
			{
				//camera.x += step;
				newx -= staminaBonus * step;
				staminaFader.amount -= staminaTrata;
				isStam = true;
			}
			if (moveRight)
			{
				//camera.x -= step;
				newx += staminaBonus * step;
				staminaFader.amount -= staminaTrata;
				isStam = true;
			}
			
			if (!isStam) {
				staminaFader.amount += staminaTrata*3;
			}
			else me.turbulum();
			
			staminaFader.amount = Math.max(0,staminaFader.amount);
			staminaFader.amount = Math.min(1,staminaFader.amount);
			
			if (STATIC.playerID != "-1") {
				STATIC.getPlayerModel().pos.x = newx;
				STATIC.getPlayerModel().pos.y = newy;
				STATIC.units.renewUnit(STATIC.playerID);
			}
			
			if (me) me.update();
		}
		
		public function onKeyUp (e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.W:
				case Keyboard.UP:
					moveUp = false;
					break;
				case Keyboard.S:
				case Keyboard.DOWN:
					moveDown = false;
					break;		
				case Keyboard.A:
				case Keyboard.LEFT:
					moveLeft = false;
					break;
				case Keyboard.D:
				case Keyboard.RIGHT:
					moveRight = false;
					break;
			}
		}
		
		public function onKeyDown(e:KeyboardEvent):void
		{		
			
			switch (e.keyCode)
			{
				case Keyboard.W:
				case Keyboard.UP:
					moveUp = true;
					break;
				case Keyboard.S:
				case Keyboard.DOWN:
					moveDown = true;
					break;		
				case Keyboard.A:
				case Keyboard.LEFT:
					moveLeft = true;
					break;
				case Keyboard.D:
				case Keyboard.RIGHT:
					moveRight = true;
					break;				
			}
		}
		
	}

}