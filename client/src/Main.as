package 
{
	import com.prograess.obvyazka.Client;
	import com.prograess.obvyazka.events.JSONEvent;
	import com.prograess.obvyazka.events.TextEvent;
	import com.prograess.zwooki.SoundQueue;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class Main extends Sprite 
	{
		[Embed(source="shot.mp3")]
		public static var shotCls:Class;

		[Embed(source="dead.mp3")]
		public static var deadCls:Class;
		
		[Embed(source="hurt.mp3")]
		public static var hurtCls:Class;
		
		[Embed(source="crow.mp3")]
		public static var crowCls:Class;		
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			stage.quality = StageQuality.LOW;
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point

			STATIC.socket = new Client('kkk.myachin.com', 443, "evol");
			//STATIC.socket = new Client('127.0.0.1', 8080, "evol");
			STATIC.socket.addEventListener(Event.CONNECT, function():void {
				trace("connected");
				addChild(new AskNameSprite);
				
				MusicMixer.playClick4();
				
				STATIC.socket.addEventListener("start", function():void {
					trace("Start game");
					removeChildAt(0);
					addChild(new GameSprite);
					MusicMixer.playDefaultTrack();
				});
			});
			
			STATIC.socket.connect();
			
			// Звуки
			SoundQueue.addToBank(shotCls, "shot");
			SoundQueue.addToBank(deadCls, "dead");
			SoundQueue.addToBank(hurtCls, "hurt");
			SoundQueue.addToBank(crowCls, "crow");
			
		}
		
	}
	
}