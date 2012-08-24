var o = require('./obvyazka');

var s = new o.Server(handler,"HI");

function handler(c,a){
	c.on("TY",function(data){
		console.log("TY: " + data);
	});
	c.sendU("YT","Hello");
}

s.listen(8080);