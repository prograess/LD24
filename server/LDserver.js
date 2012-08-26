var obvyazka = require('./obvyazka');

var unitModels = [];
var connectedPlayers = {};
var blocks = {};

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

var blockSize = 500;
var GeoMaxDist = Math.floor((3*blockSize/2));

function getRealBlock(x,y){
	var xb = Math.floor(x/blockSize)*blockSize;
	var yb = Math.floor(y/blockSize)*blockSize;
	return xb.toString() + ":" + yb.toString();
}

function initBlock(block,id){
	if (!blocks[block])blocks[block]={};
		blocks[block][id]=id;
}

function updateBlock(id){
	var oldBlock = unitModels[id].block;
	var newBlock = getRealBlock(unitModels[id].pos.x,unitModels[id].pos.y);
	if (oldBlock != newBlock){
		delete blocks[oldBlock][id];
		unitModels[id].block = newBlock;
		initBlock(newBlock,id);
	}
}

function get9BlockList(x,y){
	var res = [];
	var xs = [x-blockSize,x,x+blockSize];
	var ys = [y-blockSize,y,y+blockSize];
	for (var i in xs){
		for(var j in ys){
			var block = getRealBlock(xs[i],ys[j]);
			for(var k in blocks[block]){
				res.push(blocks[block][k]);
			}
		}
	}
	return res;
}

function dist(a,b){
	return Math.max(Math.abs(a.x - b.x),Math.abs(a.y-b.y));
}

function hitTest(shot,point){
	var ScreenHalfsize = 500;
	var maxRho = 7;
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

function runShootTest(data){
	var list = get9BlockList(data.x,data.y);
	for(var i in list){
		if(unitModels[i] && unitModels[i].type == "zombie"){
			if (hitTest(data,unitModels[i].pos)) killZombie(i);
		}
	}
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



function sendEveryFilterR(type,buf,filter){
	for(var i in connectedPlayers){
		if (filter(i)){
			connectedPlayers[i].sendR(type,buf);
		}
	}
}

function sendEveryR(type,buf,exclude){
	sendEveryFilterR(type,buf,function(i){return i!= exclude;});
}

function sendEveryGeoR(type,buf,myID){
	sendEveryFilterR(type,buf,function(i){
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
	var r = 70;

	setTimeout(function(){createZombie(spawnID);},spawnTime);
	if (zombiesTotal > maxZombies()) return;
	var coef = generateRandomLinCoef(numGenes);

	var fi = Math.random()*Math.PI*2;
	var x = spawns[spawnID].x + Math.floor(r*Math.cos(fi));
	var y = spawns[spawnID].y + Math.floor(r*Math.sin(fi));
	var block = getRealBlock(x,y);
	var obj = {type:"zombie",pos:{x:x,y:y,rot:0},block:block};
	obj.id = getfreeID();
	initBlock(block,obj.id);
	
	for (var i in paramNames){
		for(var j in coef){
			//obj[i]+=coef[j]*gene[j][i];
		}
	}
	zombiesTotal++;
	unitModels[obj.id] = obj;
	sendEveryJ('newunit',obj);
	console.log(spawnID + " createZombie "+x+" "+y);
}

function killZombie(zombieID){
	sendEveryJ('removeunit',unitModels[zombieID]);
	console.log("killZombie "+zombieID);
	unitModels[zombieID] = undefined;
}

function zombieAI(zombieID,target){
	var step = 50;
	var randstep = 10;
	var rotstep = 30;

	if (!unitModels[target]) return;
	var dx = unitModels[target].pos.x - unitModels[zombieID].pos.x;
	var dy = unitModels[target].pos.y - unitModels[zombieID].pos.y;

	var xstep = Math.min(Math.floor(Math.random()*step),Math.abs(dx)) + (Math.random()>0.5?1:-1)*Math.floor(Math.random()*randstep);
	var ystep = Math.min(Math.floor(Math.random()*step),Math.abs(dy)) + (Math.random()>0.5?1:-1)*Math.floor(Math.random()*randstep);
	var drot = Math.floor(Math.random()*rotstep);

	unitModels[zombieID].pos.x += (dx>0?1:-1)*xstep;
	unitModels[zombieID].pos.y += (dy>0?1:-1)*ystep;
	unitModels[zombieID].pos.rot += drot;
	unitModels[zombieID].pos.rot %= 360;

	updateBlock(zombieID);

	var buf = new Buffer(8);
	buf.writeUInt16LE(parseInt(zombieID),0);
	buf.writeInt16LE(parseInt(unitModels[zombieID].pos.x),2);
	buf.writeInt16LE(parseInt(unitModels[zombieID].pos.y),4);
	buf.writeInt16LE(parseInt(unitModels[zombieID].pos.rot),6);

	sendEveryGeoR('XY',buf,zombieID);
}

var AITime = 500;

function getTarget(){
	var target;
	for (var i in unitModels){
		if (unitModels[i] && unitModels[i].type == "human"){
			target = i;
			break;
		}
	}
	return target;
}

function zombieAIAll(){
	setTimeout(zombieAIAll,AITime);
	var target = getTarget();
	for (var i in unitModels){
		if (unitModels[i] && unitModels[i].type == "zombie") zombieAI(i,target);
	}
}

function createPlayer(){
	var id = getfreeID();
	var x = Math.floor(Math.random()*666);
	var y = Math.floor(Math.random()*666);
	var block = getRealBlock(x,y);
	initBlock(block,id);
	return {type:"human",pos:{x:x,y:y,rot:0},block:block,id:id};
}



var s = new obvyazka.Server(handler,"evol");

initSpawns();
zombieAIAll();

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

		console.log("name: " + data);
		console.log("ID: " + playerID);

		var p = createPlayer();
		playerID = p.id;
		unitModels[playerID] = p;
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

			updateBlock(playerID);

			var buf = new Buffer(8);
			buf.writeUInt16LE(parseInt(playerID),0);
			buf.writeInt16LE(parseInt(data.x),2);
			buf.writeInt16LE(parseInt(data.y),4);
			buf.writeInt16LE(parseInt(data.rot),6);
			sendEveryGeoR('XY',buf,playerID);
		});
		c.on('shoot',function(data){
			runShootTest(data);
			sendEveryGeoJ('shoot',data,playerID);
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