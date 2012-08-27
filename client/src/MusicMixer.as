package  
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	/**
	 * ...
	 * @author myachin
	 */
	public class MusicMixer 
	{
		[Embed(source="mixdown.mp3")]
		public static var cimusCls:Class;		
		public static var cimus:Sound = new cimusCls() as Sound; 		
	
		public static var musicChannel:SoundChannel = new SoundChannel;
		
		[Embed(source="test128.mp3")]
		//[Embed(source="dry.mp3")]
		public static var click4Cls:Class;		
		public static var click4:Sound = new click4Cls() as Sound; 		
		
		public static var _isMusic:Boolean = true;
		
		public static function get isMusic():Boolean { return _isMusic; }
		
		public static function set isMusic(value:Boolean):void 
		{
			_isMusic = value;
			if ( _isMusic == true )
				musicChannel.soundTransform = new SoundTransform(defaultVolume);
			else
				musicChannel.soundTransform = new SoundTransform(0);
		}
		
		public static var defaultVolume:Number = 0.5;
		
		public static function playDefaultTrack ():void
		{
			defaultVolume = 0.5;
			musicChannel.stop(); 
			musicChannel = cimus.play(0,10000000, new SoundTransform(defaultVolume));
		}
		
		public static function playClick4 ():void
		{
			defaultVolume = 1.0;
			musicChannel.stop(); 
			musicChannel = click4.play(0, 10000000, new SoundTransform(defaultVolume));
		}
				
				
		
	}

}