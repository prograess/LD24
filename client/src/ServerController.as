package  
{
	import com.prograess.obvyazka.events.JSONEvent;
	import com.adobe.serialization.json.JSON;
	import com.prograess.obvyazka.events.RawEvent;
	import com.prograess.zwooki.SoundQueue;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author 
	 */
	public class ServerController 
	{
		
		static public var sendMyXYInterval:int = 100;
		
		public function ServerController() 
		{
			STATIC.socket.addEventListener("yourself", onYourself);
			STATIC.socket.addEventListener("newunit", onNewunit);
			STATIC.socket.addEventListener("removeunit", onRemoveunit);
			STATIC.socket.addEventListener("unitlist", onUnitlist);
			STATIC.socket.addEventListener("XY", onXY);	
			STATIC.socket.addEventListener("shoot", onShoot);	
			STATIC.socket.addEventListener("bite", onBite);	
			STATIC.socket.addEventListener("yourdeath", onYourDeath);	
		}
		
		public static var startPlay:uint = 0;
		
		public static function onYourDeath(e:JSONEvent):void {
			GameSprite.THIS.addChild( GameSprite.death );
			GameSprite.death.show("You are dead\nYour time: "+ Math.floor((getTimer() - startPlay)/1000).toString() + "s\n\nClick to try again.");
		}
			
		public static function onShoot(e:JSONEvent):void {
			trace("shoot: " + JSON.encode(e.data));
			var b:Bullet = new Bullet(e.data.x, e.data.y, e.data.rot);
			
			var d:Number = Math.sqrt( 
				(e.data.x - GameSprite.me.x) * (e.data.x - GameSprite.me.x) +
				(e.data.y - GameSprite.me.y) * (e.data.y - GameSprite.me.y) );
			b.shoot( d );
			
			

		}
		
		public static function onBite(e:JSONEvent):void {
			trace("bite: " + JSON.encode(e.data));
			
			var id:int = e.data.id;
			
			var x:int = STATIC.unitModels[id].pos.x ;
			var y:int = STATIC.unitModels[id].pos.y ;
			
			var d:Number = Math.sqrt( 
				(x - GameSprite.me.x) * (x - GameSprite.me.x) +
				(y - GameSprite.me.y) * (y - GameSprite.me.y) );
			
			SoundQueue.play("hurt", d);
			
			GameSprite.THIS.camera.addChild( new BloodRain(x, y) )
		}		
		
		public static function onYourself(e:JSONEvent):void {
			trace("yourself: " + JSON.encode(e.data));
			STATIC.playerID = e.data.toString();
			GameSprite.me = STATIC.unitSprites[STATIC.playerID];
			sendMyXY();
		}
		
		public static function sendMyXY():void {
			STATIC.getPlayerModel().pos.x = int(STATIC.getPlayerModel().pos.x);
			STATIC.getPlayerModel().pos.y = int(STATIC.getPlayerModel().pos.y);
			STATIC.socket.sendJ("XY", STATIC.getPlayerModel().pos);
			setTimeout(sendMyXY, sendMyXYInterval);
		}
		
		public static function onNewunit(e:JSONEvent):void {
			trace("newunit: " + JSON.encode(e.data));
			
			if (!e.data.pos) e.data.pos = { x: -5550, y: -5550, rot:0 };
			
			STATIC.unitModels[e.data.id] = e.data;
			STATIC.units.addUnit(e.data.id);
		}
		
		public static function onRemoveunit(e:JSONEvent):void {
			trace("removeunit: " + JSON.encode(e.data));
			STATIC.units.deleteUnit(e.data.id);
			delete STATIC.unitModels[e.data.id];
		}
		
		public static function onUnitlist(e:JSONEvent):void {
			trace("unitlist: " + JSON.encode(e.data));
			STATIC.unitModels = e.data;
			STATIC.units.init();
		}
		
		public static function onXY(e:RawEvent):void {			
			var buf:ByteArray = e.data;
			buf.endian = Endian.LITTLE_ENDIAN;
			var id:uint;
			var ids:String;
			var x:int;
			var y:int;
			var rot:int;
			id = buf.readUnsignedShort();
			ids = id.toString();
			x = buf.readShort();
			y = buf.readShort();
			rot = buf.readShort();
			//trace("XY: " + x+" "+y+" "+rot);
			if ( STATIC.unitModels[ids] == undefined )
				STATIC.unitModels[ids] = { };
				
			(STATIC.unitSprites[id] as UnitSprite).update();	
			
			STATIC.unitModels[ids].pos = { };
			STATIC.unitModels[ids].pos.x = x;
			STATIC.unitModels[ids].pos.y = y;
			STATIC.unitModels[ids].pos.rot = rot;
			STATIC.units.renewUnit(ids);
		}
		
	}

}