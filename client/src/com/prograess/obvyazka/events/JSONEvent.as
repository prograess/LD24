package com.prograess.obvyazka.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class JSONEvent extends Event 
	{
		public var data:Object;
		public function JSONEvent(type:String, obj:Object, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			this.data = obj;
			super(type, bubbles, cancelable);
		}
		
	}

}