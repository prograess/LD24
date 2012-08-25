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

var GeoMaxDist = 1000;

function dist(a,b){
	return Math.max(Math.abs(a.x - b.x),Math.abs(a.y-b.y));
}

function sendEveryFilterJ(type,obj,filter){
	for(var i in connectedPlayers){
		if (filter(i)){
			connectedPlayers[i].sendJ(type,obj);
		}
	}
}

function sendEveryJ(type,obj,exclude){
	sendEveryFilterJ(type,obj,function(i){return i!= exclude;});
}

function sendEveryGeoJ(type,obj,myID){
	sendEveryFilterJ(type,obj,function(i){
		if (i==myID) return false;
		return (dist(unitModels[i].pos,unitModels[myID].pos) < GeoMaxDist);
	});
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

function createZombie(spawnID){
	//if too much zombies return
	//add zombie
	// sendEveryJ('newunit',{zombieobject})
	//setTimeout(spawnTime,function(){createZombie(spawnID)})
}

function createPlayer(){
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
		if (playerID != -1) return;
		playerID = getfreeID();

		console.log("name: " + data);
		console.log("ID: " + playerID);

		unitModels[playerID] = createPlayer();
		unitModels[playerID].id = playerID;
		connectedPlayers[playerID] = c;
		c.sendJ("start",{});
		var unitlist = {};
		for (var i in unitModels){
			if (unitModels[i]){
				unitlist[i] = unitModels[i];
			}
		}
		c.sendJ("unitlist",unitlist);
		c.sendJ("yourself",playerID);
		sendEveryJ('newunit',unitModels[playerID],playerID);
		console.log("start");

		c.on('XY',function(data){
			unitModels[playerID].pos = data;
			sendEveryGeoJ('XY',data);
		});
	});

	c.on('close',function(){
		if (playerID === -1) return;

		sendEveryJ('removeunit',unitModels[playerID],playerID);
		delete connectedPlayers[playerID];
		unitModels[playerID] = undefined;
	});
}

s.listen(8080);