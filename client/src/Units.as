package  
{
	import com.prograess.zwooki.SoundQueue;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class Units extends Sprite
	{		
		
		public function Units() 
		{
		}
		
		public function init():void {
			trace('init');
			for (var i:String in STATIC.unitModels)
			{
				addUnit(i);
			}
		}
		
		/*public function Units(sprites:Array, models:Array)
		{
			STATIC.unitModels = models;	
			for (var i:uint in STATIC.unitModels)
			{
				if (STATIC.unitModels[i]["id"] != STATIC.playerID)
				{
					addUnit(STATIC.unitModels[i]["id"], STATIC.unitModels[i]["pos"]["x"], STATIC.unitModels[i]["pos"]["y"], STATIC.unitModels[i]["pos"]["rot"]);
				}
			}
		}*/
		
		public function renewUnit (id:String):void
		{			
			(STATIC.unitSprites[id] as UnitSprite).rx = STATIC.unitModels[id].pos.x;
			(STATIC.unitSprites[id] as UnitSprite).ry = STATIC.unitModels[id].pos.y;
			STATIC.unitSprites[id].rotation = STATIC.unitModels[id].pos.rot;
		}
		
		public function addUnit(id:String):void
		{
			var newUnit:UnitSprite;
			switch(STATIC.unitModels[id].type) {
			case "human":
				newUnit = new Human( STATIC.unitModels[id].name );
				break;
			case "zombie":
				newUnit = new Zombie( STATIC.unitModels[id].gene.outfit, id.toString() );
				break;
			case "spawn":
				newUnit = new Spawn();
				break
			}
			newUnit.rx = STATIC.unitModels[id].pos.x;
			newUnit.ry = STATIC.unitModels[id].pos.y;
			newUnit.rotation = STATIC.unitModels[id].pos.rot;
			this.addChild(newUnit);
			STATIC.unitSprites[id] = newUnit;
		}
		
		public function deleteUnit(id:String):void
		{
			var color:uint = 0xff0000;
			if ( STATIC.unitModels[id].type == "zombie" )
			{
				SoundQueue.play("dead");
				color = Zombie.bloodcolors[((STATIC.unitModels[id].gene.outfit & 0x00f00000) >> 20)]  ;
			}
			
			GameSprite.THIS.camera.addChild( new BloodRain(STATIC.unitSprites[id].x, STATIC.unitSprites[id].y, color) )
			this.removeChild(STATIC.unitSprites[id]);
			delete STATIC.unitSprites[id];
		}
	}

}