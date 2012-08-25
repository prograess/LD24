package  
{
	import com.prograess.obvyazka.Client;
	/**
	 * ...
	 * @author 
	 */
	public class STATIC 
	{
		
		public static var socket:Client;
		public static var unitModels:Object = new Object;
		public static var unitSprites:Object = new Object;
		public static var units:Units = new Units;
		public static var playerID:String = "-1";
		public static var sc:ServerController;
		
		public static function getPlayerModel():Object {
			return unitModels[playerID];
		}
				
		public function STATIC() 
		{
		}
		
	}

}