package com.prograess.obvyazka 
{
	import com.adobe.serialization.json.JSON;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.errors.IOError;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import com.prograess.obvyazka.events.JSONEvent;
	import com.prograess.obvyazka.events.RawEvent;
	import com.prograess.obvyazka.events.TextEvent;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ProgressEvent;
	/**
	 * ...
	 * @author 
	 */
	public class Client extends EventDispatcher
	{
		private var c:Socket;
		private var helo_phrase:String;
		private var receiveBuffer:ByteArray;
		private var host:String;
		private var port:uint;
		public function Client(host:String, port:uint, helo_phrase:String) 
		{
			this.host = host;
			this.port = port;
			this.helo_phrase = helo_phrase;
			c = new Socket();
			receiveBuffer = new ByteArray();
			receiveBuffer.endian = Endian.LITTLE_ENDIAN;
			
			c.addEventListener(Event.CLOSE, closeHandler);
			c.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			c.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			c.addEventListener(Event.CONNECT, connectHandler);
			
			Security.loadPolicyFile("xmlsocket://" + host + ':' + port + "/crossdomain.xml");
		}
		
		public function connect():void {
			c.connect(host, port);
		}
		
		private function connectHandler(e:Event):void {
			c.writeUTFBytes(helo_phrase);
			c.flush();
			dispatchEvent(e);
			c.addEventListener(ProgressEvent.SOCKET_DATA, onData);
		}
		
		private function onData(e:Event):void {
			var buf:ByteArray;
			buf = new ByteArray();
			buf.endian = Endian.LITTLE_ENDIAN;
			//Read socket to temp buffer
			c.readBytes(buf);
			//Write temp buffer to end of receive buffer
			receiveBuffer.position = receiveBuffer.length;
			receiveBuffer.writeBytes(buf);
			//Set position back to begin of receive buffer
			receiveBuffer.position = 0;
			
			translateMessageCycle();
		}
		
		private function translateMessageCycle():void
		{
			const HEADER_LENGTH:uint = 3; //1 byte for format and 2 for len
			var format:String = "";
			var length:uint = 0;
			var message:ByteArray = new ByteArray();
			message.endian = Endian.LITTLE_ENDIAN;
			//If not enough data to determine format and length
			while (receiveBuffer.length > HEADER_LENGTH)
			{
				format = receiveBuffer.readUTFBytes(1);
				length = receiveBuffer.readUnsignedShort();

				if (length <= receiveBuffer.length-3){
					receiveBuffer.readBytes(message, 0, length);
					translateMessage(format,message);
					message = new ByteArray();
					message.endian = Endian.LITTLE_ENDIAN;
					length = 0;

					var newBuf:ByteArray = new ByteArray();
					newBuf.endian = Endian.LITTLE_ENDIAN;
					newBuf.writeBytes(receiveBuffer,receiveBuffer.position);
					receiveBuffer = newBuf;
					receiveBuffer.position = 0;
				}
				else
				{
					return;
				}
			}
		}
		
		private function translateMessage(format:String,msg:ByteArray):void
		{
			var type:String = "";
			var str:String = "";
			var obj:Object;
			var buf:ByteArray = new ByteArray();
			switch (format){
			case "U":
				str = msg.toString();
				type = str.substr(0,2);
				str = str.substr(2);
				this.dispatchEvent(new TextEvent(type, str));
				break;
			case "R":
				type = msg.readUTFBytes(2);
				msg.readBytes(buf);
				this.dispatchEvent(new RawEvent(type,buf));
				break;
			case "J":
				str = msg.toString();
				var parsedObj:Object = JSON.decode(str);
				for (var k:String in parsedObj){
					type = k;
					obj = parsedObj[k];
				}
				this.dispatchEvent(new JSONEvent(type,obj));
				break;
			default:
				trace("obvyazka: unknown message format");
				return;
			}
		}
		
		private function sendMessage(pre:String,len:uint,msg:ByteArray):void
		{
			const MAX_MSG_LEN:uint = 65500;
			if (len==0 || msg.length === 0)
				return;
				
			if (len > MAX_MSG_LEN) {
				trace("obvyazka: msg is too big");
				return;
			}

			var lenBuffer:ByteArray = new ByteArray();
			lenBuffer.endian = Endian.LITTLE_ENDIAN;
			lenBuffer.writeInt(len);
			
			var lenBuffer2:ByteArray = new ByteArray();
			lenBuffer2.endian = Endian.LITTLE_ENDIAN;
			lenBuffer2.writeBytes(lenBuffer, 0, 2);
			
			c.writeUTFBytes(pre);
			c.writeBytes(lenBuffer2);
			c.writeBytes(msg);
			c.flush();
		}
		
		public function sendU(type:String,str:String):void
		{
			var buf:ByteArray = new ByteArray();
			buf.endian = Endian.LITTLE_ENDIAN;
			buf.writeUTFBytes(type + str);
			sendMessage('U',buf.length,buf);
		}
		
		public function sendR(type:String,buf:ByteArray):void
		{
			var sendBuf:ByteArray = new ByteArray();
			sendBuf.endian = Endian.LITTLE_ENDIAN;
			sendBuf.writeUTFBytes(type);
			sendBuf.writeBytes(buf);
			sendMessage('R',sendBuf.length,sendBuf);
		}
		public function sendJ(type:String,obj:Object):void
		{
			var sendObj:Object = {};
			sendObj[type]=obj;
			var str:String = JSON.encode(sendObj);
			var buf:ByteArray = new ByteArray();
			buf.endian = Endian.LITTLE_ENDIAN;
			buf.writeUTFBytes(str);
			sendMessage('J',buf.length,buf);
		};

		
		private function closeHandler(e:Event):void {
			trace('obvyazka: connection closed');
			this.dispatchEvent(e);
		}
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace('obvyazka: io error' + JSON.encode(event) );
			this.dispatchEvent(event);
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void {
			trace('obvyazka: security error' + JSON.encode(event) );
			this.dispatchEvent(event);
		}
		
	}

}