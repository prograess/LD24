package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class AskNameSprite extends Sprite 
	{
		public var enterNameTF:TextField;
		public var nameTF:TextField;
		public var okBtn:ButtonSprite;
		
		public function AskNameSprite() 
		{
			enterNameTF = new TextField();
			enterNameTF.height = 30;
			enterNameTF.text = "enter your name";
			
			nameTF = new TextField();
			nameTF.y = 50;
			nameTF.type = TextFieldType.INPUT;
			nameTF.border = true;
			nameTF.height = 30;
			
			okBtn = new ButtonSprite();
			okBtn.x = 100;
			okBtn.y = 50;
			okBtn.graphics.lineStyle(2, 0x888888);
			okBtn.graphics.beginFill(0x888888);
			okBtn.graphics.drawRect(0, 0, 50, 30);
			
			okBtn.addEventListener(MouseEvent.CLICK, function():void {
				if (nameTF.text != ""){
					OBVYAZKA.socket.sendJ("name", nameTF.text);
				}
			});
			
			addChild(okBtn);
			addChild(nameTF);
			addChild(enterNameTF);
		}
		
	}

}