var obvyazka = require('./obvyazka');

var unitModels = [];
var connectedPlayers = {};

var spawns = [];

function getfreeID(){
	for (var i in unitModels){
		if (unitModels[i] === undefined){
			unitModels[i] = 'reserved';
			return i;
		}
	}
	unitModels.push("reserved");
	return unitModels.length-1;
}

var GeoMaxDist = 1000;

function dist(a,b){
	return Math.max(Math.abs(a.x - b.x),Math.abs(a.y-b.y));
}

function hitTest(shot,point){
	var ScreenHalfsize = 500;
	var maxRho = 5;
	var eps = 0.00001;

	if (Math.abs(shot.x - point.x) <= eps && Math.abs(shot.y - point.y) <= eps) return true;

	var dx = point.x - shot.x;
	var dy = point.y - shot.y;
	if (Math.abs(dx) > ScreenHalfsize || Math.abs(dy) > ScreenHalfsize)return false;
	var d2 = dx*dx + dy*dy;
	var d = Math.sqrt(d2);
	var sx = Math.cos(shot.rot*Math.PI/180);
	var sy = Math.sin(shot.rot*Math.PI/180);
	var cos = (sx*dx + sy*dy)/d;
	if (cos <= eps )return false;
	var rho = Math.sqrt(1-cos*cos)*d;
	return rho < maxRho;
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
var spawnTime = 3000;
var numGenes = 4;

function initSpawns()
{
	for (var i=0;i<initialSpawns;i++)
	{
		createRandomSpawn();
	}
}

var paramNames = ['ATK','VIT','SPD','ASPD'];

function createRandomSpawn()
{
	//Init random genes
	createSpawn();
}

function createSpawn()
{
	var xSize = 1000;
	var ySize = 1000;

	//FIXME
	//init genes
	//add to models
	var obj = {};
	obj.x= Math.floor(xSize*Math.random());
	obj.y= Math.floor(ySize*Math.random());
	//sendEveryJ("newunit",{spawnobject});
	spawns.push(obj);
	createZombie(spawns.length-1);
	console.log("createSpawn " + obj.x + " " + obj.y);
}

function generateRandomLinCoef(num){
	var coef = [];
	var sum = 0;
	var cur = 0;
	for(var i=0;i<num;i++){
		cur = sum*Math.random();
		coef.push(cur);
		sum+=cur;
	}
	for(var i in coef){
		coef[i] /= sum;
	}
	return coef;
}

function maxZombies(){
	var zombiesPerPlayer = 200;

	var count = 0;
	for (var i in connectedPlayers){
		count++;
	}
	return count*zombiesPerPlayer+10;
}

var zombiesTotal = 0;

function createZombie(spawnID){
	setTimeout(function(){createZombie(spawnID);},spawnTime);
	if (zombiesTotal > maxZombies()) return;
	var coef = generateRandomLinCoef(numGenes);

	var r = 30;
	var fi = Math.random()*Math.PI*2;
	var x = spawns[spawnID].x + Math.floor(r*Math.cos(fi));
	var y = spawns[spawnID].y + Math.floor(r*Math.sin(fi));
	var obj = {type:"zombie",pos:{x:x,y:y,rot:0}};
	obj.id = getfreeID();
	
	for (var i in paramNames){
		for(var j in coef){
			//obj[i]+=coef[j]*gene[j][i];
		}
	}
	zombiesTotal++;
	unitModels[obj.id] = obj;
	sendEveryJ('newunit',obj);
	console.log("createZombie "+x+" "+y);
}

function createPlayer(){
	return {type:"human",pos:{x:Math.floor(Math.random()*100),y:Math.floor(Math.random()*100),rot:0}};
}



var s = new obvyazka.Server(handler,"evol");

initSpawns();

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
			var obj = {id:playerID,pos:data};
			sendEveryGeoJ('XY',obj,playerID);
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