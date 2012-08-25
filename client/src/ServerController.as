package  
{
	import com.prograess.obvyazka.events.JSONEvent;
	import com.adobe.serialization.json.JSON;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author 
	 */
	public class ServerController 
	{
		
		static var sendMyXYInterval:int = 100;
		
		public function ServerController() 
		{
			STATIC.socket.addEventListener("yourself", onYourself);
			STATIC.socket.addEventListener("newunit", onNewunit);
			STATIC.socket.addEventListener("removeunit", onRemoveunit);
			STATIC.socket.addEventListener("unitlist", onUnitlist);
			STATIC.socket.addEventListener("XY", onXY);			
		}
		
		public static function onYourself(e:JSONEvent):void {
			trace("yourself: " + JSON.encode(e.data));
			STATIC.playerID = e.data.toString();
			GameSprite.me = STATIC.unitSprites[STATIC.playerID];
			sendMyXY();
		}
		
		public static function sendMyXY():void {
			STATIC.socket.sendJ("XY", STATIC.getPlayerModel().pos);
			setTimeout(sendMyXY, sendMyXYInterval);
		}
		
		public static function onNewunit(e:JSONEvent):void {
			trace("newunit: " + JSON.encode(e.data));
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
		
		public static function onXY(e:JSONEvent):void {			
			trace("XY: " + JSON.encode(e.data));
			if ( STATIC.unitModels[e.data.id] == undefined )
				STATIC.unitModels[e.data.id] = { };
				

			STATIC.unitModels[e.data.id].pos = e.data.pos;
			STATIC.units.renewUnit(e.data.id);
		}
		
	}

}