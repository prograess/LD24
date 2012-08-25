package  
{
	import com.prograess.obvyazka.events.JSONEvent;
	import com.adobe.serialization.json.JSON;
	/**
	 * ...
	 * @author 
	 */
	public class ServerController 
	{
		
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
			STATIC.playerID = uint(e.data);
		}
		
		public static function onNewunit(e:JSONEvent):void {
			trace("newunit: " + JSON.encode(e.data));
			STATIC.unitModels[e.data.id] = e.data;
			//FIXME init sprite
		}
		
		public static function onRemoveunit(e:JSONEvent):void {
			trace("removeunit: " + JSON.encode(e.data));
			delete STATIC.unitModels[e.data.id];
			//FIXME free sprite
		}
		
		public static function onUnitlist(e:JSONEvent):void {
			trace("unitlist: " + JSON.encode(e.data));
			STATIC.unitModels = e.data;
			//FIXME init unitsprites
		}
		
		public static function onXY(e:JSONEvent):void {
			trace("XY: " + JSON.encode(e.data));
			STATIC.unitModels[e.data].pos = e.data.pos;
			//FIXME init unitsprites
		}
		
	}

}