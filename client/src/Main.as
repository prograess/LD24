package 
{
	import com.prograess.obvyazka.Client;
	import com.prograess.obvyazka.events.TextEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	
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
			
			OBVYAZKA.socket = new Client('kkk.myachin.com', 8080, "HI");
			
			OBVYAZKA.socket.addEventListener(Event.CONNECT,function():void{
				OBVYAZKA.socket.addEventListener("YT", function(event:TextEvent):void { trace("YT " + event.data); } );
				OBVYAZKA.socket.sendU("TY", "Hi there");
			});
			
			OBVYAZKA.socket.connect();
		}
		
	}
	
}