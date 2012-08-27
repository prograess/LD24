package com.prograess.zwooki 
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.getTimer;	
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author myachin
	 */
	public class SoundQueue 
	{
		public static var soundBank:Object = { };		
		public static var isSound:Boolean = true;
		public static var soundChannel:SoundChannel = null
		
		public static var lastPlays:Object = { };		
		
		public static function addToBank ( soundClass:Class, soundName:String, defaultVolume:Number = 1.0 ) : void
		{
			soundBank[ soundName ]  = { volume: defaultVolume } ;
			soundBank[ soundName ][ "class" ] = new soundClass as Sound;
		}
		
		public static function play( soundName:String, distance:Number = 0 ):void
		{
			if (lastPlays[soundName] != undefined)
			{
				// Только что играли этот звук?!
				if (( lastPlays[soundName] + 50 > getTimer() ) && ( lastPlays[soundName] <= getTimer() + 1 ) )
				{
					var delay:int = 10 + Math.random() * 20;
					// setTimeout(  function():void { play(soundName, distance); }, delay  );
					
					//lastPlays[soundName] += delay;
					return;
				}
			}
			
			if (!SoundQueue.isSound) 
				return;
				
			// TODO: реализовать очередь звуков: хранить количество проигрываний и делать паузы между началами
			if (soundBank[soundName]["class"] as Sound)
				soundChannel = (soundBank[soundName]["class"] as Sound).play();
			
			soundChannel.soundTransform = new SoundTransform( soundBank[soundName].volume * Math.min(1.0, 5.0/distance ));
			
			lastPlays[soundName] = getTimer();
		}		
	}

}