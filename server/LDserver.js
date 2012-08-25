var obvyazka = require('./obvyazka');

var unitModels = [];
var connectedPlayers = [];

function getfreeID(){
	for (var i in connectedPlayers){
		if (connectedPlayers[i] === undefined) return i;
	}
	connectedPlayers.push(undefined);
	return connectedPlayers.length-1;
}





var s = new obvyazka.Server(handler,"evol");

function handler(c,a){
	var id = -1;
	c.on("name",function(data){
		console.log("name: " + data);
		id = getfreeID();
		connectedPlayers[id] = {name:data.name};
		c.sendJ("start",{});
		console.log("start");
	});

	c.on('close',function(){
		if (id === -1) return;
		connectedPlayers[id] = undefined;
	});
}

s.listen(8080);