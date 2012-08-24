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
			
			var c:Client = new Client('kkk.myachin.com', 8080, "HI");
			
			c.addEventListener(Event.CONNECT,function():void{
				c.addEventListener("YT", function(event:TextEvent):void { trace("YT " + event.data); } );
				c.sendU("TY", "Hi there");
			});
			
			c.connect();
		}
		
	}
	
}