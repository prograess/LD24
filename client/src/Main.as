package 
{
	import com.prograess.obvyazka.Client;
	import com.prograess.obvyazka.events.JSONEvent;
	import com.prograess.obvyazka.events.TextEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			OBVYAZKA.socket = new Client('kkk.myachin.com', 8080, "evol");
			OBVYAZKA.socket.addEventListener(Event.CONNECT, function():void {
				trace("connected");
				addChild(new AskNameSprite);
				OBVYAZKA.socket.addEventListener("start", function():void {
					trace("Start game");
//					removeChildAt(0);
//					addChild(new GameSprite);
				});
			});
			
			OBVYAZKA.socket.connect();
			
		}
		
	}
	
}