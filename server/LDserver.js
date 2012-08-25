var obvyazka = require('./obvyazka');

var unitModels = [];
var connectedPlayers = {};

function getfreeID(){
	for (var i in unitModels){
		if (unitModels[i] === undefined) return i;
	}
	unitModels.push(undefined);
	return unitModels.length-1;
}

var initialSpawns = 5;
var spawnTime = 10000;

function initSpawns()
{
	for (var i=0;i<initialSpawns;i++)
	{
		createRandomSpawn();
	}
}

function createRandomSpawn()
{
	//FIXME
	//Init random genes
	createSpawn();
}

function createSpawn()
{
	//FIXME
	//init random coords
	//init genes
	//add to models
	//sendEveryJ("newunit",{spawnobject});
	//setTimeout(spawnTime,function(){createZombie(spawnID)})
}

function sendEveryJ(type,obj,exclude){
	for(var i in connectedPlayers){
		if (i != exclude){
			connectedPlayers[i].sendJ(type,obj);
		}
	}
}

function createZombie(spawnID){
	//if too much zombies return
	//add zombie
	// sendEveryJ('newunit',{zombieobject})
	//setTimeout(spawnTime,function(){createZombie(spawnID)})
}

function newPlayer(){
	//FIXME
	return {};
}



var s = new obvyazka.Server(handler,"evol");

function handler(c,a){
	console.log(JSON.stringify(unitModels));
	var s = "connected: ";
	for (var i in connectedPlayers){
		s+= i;
	}
	console.log(s);

	var playerID = -1;
	c.on("name",function(data){
		playerID = getfreeID();

		console.log("name: " + data);
		console.log("ID: " + playerID);

		unitModels[playerID] = newPlayer();
		connectedPlayers[playerID] = c;
		c.sendJ("start",{});
		c.sendJ("yourself",unitModels[playerID]);
		var unitlist = {};
		for (var i in unitModels){
			if (unitModels[i]){
				unitlist[i] = unitModels[i];
			}
		}
		c.sendJ("unitlist",unitlist);
		sendEveryJ('newunit',unitModels[playerID],playerID);
		console.log("start");

		//FIXME
		//init game event listeners
	});

	c.on('close',function(){
		if (playerID === -1) return;

		sendEveryJ('removeunit',unitModels[playerID],playerID);
		delete connectedPlayers[playerID];
		unitModels[playerID] = undefined;
	});
}

s.listen(8080);