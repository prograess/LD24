var obvyazka = require('./obvyazka'),
	daemon = require('daemon');

var daemonMode = false;
process.argv.forEach(function (val, index, array) {
	var argumentPair = val.split("=");
	switch ( argumentPair[0] )
	{
	case "--daemon":
	case "-d":
		daemonMode = true;
		break;
	}
});




var unitModels = [];
var unitServerModels = [];
var connectedPlayers = {};
var blocks = {};
var DNA = {};
var props = [
{
	name:"accel",
	type:"float",
	min:1,
	max:10,
	def:1
},
{
	name:"friction",
	type:"float",
	min: 0.5,
	max: 0.9,
	def:0.6
},
{
	name:"stepW",
	type:"float",
	min:0,
	max:25,
	def:5
},
{
	name:"speedPrediction",
	type:"float",
	min:-20,
	max:20,
	def:0
},
{
	name:"repeatMotion",
	type:"float",
	min:-0.5,
	max:0.5,
	def:0
},
{
	name:"spirality",
	type:"float",
	min:-0.6,
	max:0.6,
	def:0
},
{
	name:"raidus",
	type:"float",
	min:10,
	max:400,
	def:10
},
{
	name:"revision",
	type:"float",
	min:0,
	max:0.05,
	def:0
},
{
	name:"attraction",
	type:"float",
	min:-1,
	max:1,
	def:0
},
{
	name:"flock",
	type:"float",
	min:-1,
	max:1,
	def:0
},
{
	name:"outfit",
	type:"halfbyte",
	min:0,
	max:0xffffffff,
	def:0
}
];

var worldLeft = -3000;
var worldRight = 3000;
var worldTop = -3000;
var worldBottom = 3000;

function capCoords(c){
	c.x = Math.min(c.x,worldRight);
	c.x = Math.max(c.x,worldLeft);
	c.y = Math.min(c.y,worldBottom);
	c.y = Math.max(c.y,worldTop);
}

function getRandom(min,max){
	return Math.random()*(max-min) + min;
}

var DNAlen = 200;

function generateRandomDNA(){
	var emptyProb = 0.75;
	var res = [];
	var prop,type,val,name,obj;
	for(var i =0;i<DNAlen;i++){
		if (Math.random() < emptyProb){
			name='empty';
			val = 0;
			obj = {empty:1};
		}
		else{
			prop = Math.floor(getRandom(0,props.length));
			name = props[prop].name;
			type = props[prop].type;
			if (type == 'float'){
				val = getRandom(props[prop].min,props[prop].max);
			}
			else if (type == "halfbyte"){
				var shift = Math.floor(getRandom(0,8))*4;
				val = {shift:shift,val:Math.floor(getRandom(0,16))};
			}
			obj = {name:name,type:type,val:val};
		}
		res.push(obj);
	}
	return res;
}

function makeDNAFromDNAS(dnas){
	var curDNA = (Math.random()<0.5?1:0);
	var res = [];
	for(var i=0;i<DNAlen;i++){
		if (Math.random()<0.05){
			curDNA++;
			curDNA%=2;
		}
		res.push(dnas[curDNA][i]);
	}
	return res;
}

function makeGeneFromDNA(dna){
	var gene={};
	for (var i in props){
		gene[props[i].name]=props[i].def;
	}
	var name,type,val;
	for(var i=0;i<DNAlen;i++){
		if (dna[i].empty) continue;
		if (Math.random()<0.5)continue;
		name = dna[i].name;
		type = dna[i].type;
		val = dna[i].val;

		if (type == 'halfbyte'){
			gene[name] &= ~(0xf<<val.shift);
			gene[name] |= val.val<<val.shift;
		}
		else if (type == "float"){
			if (gene[name] * val >= 0){ //same sign
				if (Math.abs(val) > Math.abs(gene[name])) gene[name] = val;
			}
			else{
				if (Math.random() < 0.5) gene[name] = val;
			}
		}
	}
	return gene;
}

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

var blockSize = 400;
var GeoMaxDist = Math.floor((3*blockSize/2));

function getRealBlock(x,y){
	var xb = Math.floor(x/blockSize)*blockSize;
	var yb = Math.floor(y/blockSize)*blockSize;
	return xb.toString() + ":" + yb.toString();
}

function initBlock(block,id){
	if (!blocks[block])
		blocks[block]={};
	blocks[block][id]=id.toString();
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

function getBlockList(x,y){
	var res = [];
	var block = getRealBlock(x,y);
	for(var k in blocks[block]){
		res.push(blocks[block][k]);
	}
	return res;
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

function distCube(a,b){
	return Math.max(Math.abs(a.x - b.x),Math.abs(a.y-b.y));
}

function sqr(a){
	return a*a;
}

function distSphere(a,b){
	return Math.sqrt(sqr(a.x - b.x)+sqr(a.y-b.y));
}

function normSphere(a){
	return distSphere({x:0,y:0},a);
}

function hitTest(shot,point){
	var ScreenHalfsize = 500;
	var maxRho = 13;
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
	//console.log(JSON.stringify(data));
	var list = get9BlockList(data.x,data.y);
	for(var j in list){
		var i = list[j];
		if(unitModels[i] && unitModels[i].type == "zombie"){
			if (hitTest(data,unitModels[i].pos)) 
			{
				unitModels[i].h--;
				if (unitModels[i].h < 0) killZombie(i);
				else 
				{
					sendEveryGeoJ("hurt",{id:i},i);					
				}
			}
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
		return (distCube(unitModels[i].pos,unitModels[myID].pos) < GeoMaxDist);
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
		return (distCube(unitModels[i].pos,unitModels[myID].pos) < GeoMaxDist);
	});
}



var initialSpawns = 5;
var spawnTime = 500;
var numGenes = 4;
var spawnMaxZombies = 250;

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
	var dnas = [];
	dnas.push(generateRandomDNA());
	dnas.push(generateRandomDNA());
	createSpawn(dnas);
}

function createSpawn(dnas)
{
	var id = getfreeID();
	var x = Math.floor(getRandom(worldLeft,worldRight));
	var y = Math.floor(getRandom(worldTop,worldBottom));
	var rot = 0;
	var block = getRealBlock(x,y);
	var obj = {id:id,pos:{x:x,y:y,rot:rot},block:block,type:"spawn",zombiesLeft:spawnMaxZombies};
	unitModels[id] = obj;
	DNA[id] = dnas;
	initBlock(block,id);
	sendEveryJ("newunit",obj);
	createZombie(id);
	console.log("createSpawn " + x + " " + y);
}

function removeUnit( id )
{
	var u = {id:id, type:unitModels[id].type};
	sendEveryJ('removeunit', u);
}

function killSpawn(sid){
	removeUnit(sid);
	console.log("killSpawn "+sid);
	delete blocks[unitModels[sid].block][sid];

	unitModels[sid] = undefined;
	DNA[sid] = undefined;
}

function getTopZombies(c){
	var res = [];
	var arr = [];
	for (var i in unitModels){
		if (unitModels[i] && unitModels[i].type == "zombie")
			arr.push(i);
	}
	arr.sort(function(a,b){
		return unitModels[a].rating < unitModels[b].rating;
	});
	res = arr.slice(0,5);
	return res;
}

function createTopSpawn(){
	console.log("CreateTopSpawn");
	var dnas = [];
	var zs = getTopZombies(5);
	var i = Math.floor(getRandom(0,5));
	var j = i;
	while ( j == i ){
		j = Math.floor(getRandom(0,5));
	}
	console.log(unitModels[zs[i]].rating + " " + unitModels[zs[j]].rating);
	dnas.push(DNA[zs[i]]);
	dnas.push(DNA[zs[j]]);
	createSpawn(dnas);
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
	var zombiesPerPlayer = 100;

	var count = 0;
	for (var i in connectedPlayers){
		count++;
	}
	return Math.min(1000,count*zombiesPerPlayer+10);
}

var zombiesTotal = 0;

function createZombie(spawnID){
	if (unitModels[spawnID].zombiesLeft == 0){
		killSpawn(spawnID);
		createTopSpawn();
		return;
	}

	unitModels[spawnID].zombiesLeft--;

	var r = 70;

	setTimeout(function(){createZombie(spawnID);},spawnTime + Math.floor(getRandom(-100,100)));
	if (zombiesTotal > maxZombies()) return;
	var coef = generateRandomLinCoef(numGenes);

	var fi = Math.random()*Math.PI*2;
	var x = unitModels[spawnID].pos.x + Math.floor(r*Math.cos(fi));
	var y = unitModels[spawnID].pos.y + Math.floor(r*Math.sin(fi));
	var block = getRealBlock(x,y);
	var dna = makeDNAFromDNAS(DNA[spawnID]);
	var gene = makeGeneFromDNA(dna);
	var obj = {type:"zombie",pos:{x:x,y:y,rot:0},block:block,ai:{dx:0,dy:0,step:0},gene:gene,rating:0,h:2};
	
	capCoords(obj.pos);
	obj.id = getfreeID();
	DNA[obj.id] = dna;
	initBlock(block,obj.id);
	
	for (var i in paramNames){
		for(var j in coef){
			//obj[i]+=coef[j]*gene[j][i];
		}
	}
	
	zombiesTotal++;
	unitModels[obj.id] = obj;
	
	var u = {type:obj.type, id:obj.id, outfit:obj.gene.outfit};
	
	
	sendEveryJ('newunit',u);
	
	zombieAI(obj.id);
}

function killZombie(zombieID){
	removeUnit(zombieID);
	//console.log("killZombie "+zombieID);
	delete blocks[unitModels[zombieID].block][zombieID];

	unitModels[zombieID] = undefined;
	DNA[zombieID] = undefined;
	zombiesTotal--;
}

function removeAITarget(id){
	for (var i in unitModels){
		if (unitModels[i] && unitModels[i].ai && unitModels[i].ai.target == id){
			unitModels[i].ai.target = undefined;
		}
	}
}

function zombieAI(zombieID){
	var z = unitModels[zombieID];
	
	if (z == undefined) return;
	
	setTimeout(
		function(){ zombieAI(zombieID);}
		,AITime + Math.random()*AITime);

	
	var ai = z.ai;
	var gene = z.gene;

	var randstep = 10;
	var rotstep = 30;

	var min = 100000;
	if (ai.target === undefined || !unitModels[ai.target] || Math.random()<gene.revision){
		for (var i in connectedPlayers){
			if (unitModels[i].pos.x<worldLeft - 1000) continue;
			var d = distSphere(z.pos,unitModels[i].pos);
			if (min > d){
				d= min;
				ai.target = i;
			}
		}
	}

	if (ai.target === undefined) return;

	var targetX = unitModels[ai.target].pos.x;
	var targetY = unitModels[ai.target].pos.y;

	var dist = distSphere(unitModels[ai.target].pos,z.pos);
	var nx,ny,norm;
	if (dist < gene.radius){
		nx = targetX;
		ny = targetY;
		norm = normSphere({x:nx,y:ny});
		nx /=norm;
		ny /=norm;
	}
	else{

		targetX += gene.speedPrediction*unitModels[ai.target].lastdx;
		targetY += gene.speedPrediction*unitModels[ai.target].lastdy;

		nx = targetX - z.pos.x - gene.spirality*(targetY - z.pos.y);
		ny = targetY - z.pos.y + gene.spirality*(targetX - z.pos.x);
		norm = normSphere({x:nx,y:ny});
		var ang = Math.floor((Math.atan2(ny,nx)*180/Math.PI));
		nx /=norm;
		ny /=norm;
		
		nx += gene.repeatMotion * unitModels[ai.target].lastdx;
		ny += gene.repeatMotion * unitModels[ai.target].lastdy;

		var centX,centY,minD,minD_id,D;
		centX = centY = 0;
		minD = 1000000;
		minD_id = -1;
		var list = get9BlockList(z.pos.x,z.pos.y);
		for (var i in list){
			centX += unitModels[list[i]].pos.x;
			centY += unitModels[list[i]].pos.y;
			D = distSphere(z.pos,unitModels[list[i]]);
			if (D < minD){
				minD_id = list[i];
				minD = D;
			}
		}
		centX /= list.length;
		centY /= list.length;
		norm = normSphere({x:centX,y:centY});
		centX /= norm;
		centY /= norm;
		nx += gene.flock*centX;
		ny += gene.flock*centY;

		var mmx,mmy;
		mmx = mmy = 0;

		if (minD_id != -1){
			mmx = unitModels[minD_id].pos.x;
			mmy = unitModels[minD_id].pos.y;
			var mmn = normSphere({x:mmx,y:mmy});
			mmx /= mmn;
			mmy /= mmn;
		}
		
		nx += gene.attraction * mmx;
		ny += gene.attraction * mmy;

		norm = normSphere({x:nx,y:ny});
		nx /=norm;
		ny /=norm;
		

		if (ai.step){
			ai.dx += gene.stepW * -ny;
			ai.dy += gene.stepW * nx;
			ang -= 10;

			ai.step = 0;
		}
		else{
			ai.dx += gene.stepW * ny;
			ai.dy += gene.stepW * -nx;
			ang += 10;

			ai.step = 1;
		}

	}

	ai.dx += gene.accel * nx;
	ai.dy += gene.accel * ny;


	var drot = Math.floor(Math.random()*rotstep);

	unitModels[zombieID].pos.x += Math.floor(ai.dx);
	unitModels[zombieID].pos.y += Math.floor(ai.dy);
	
	ai.dx *= gene.friction;
	ai.dy *= gene.friction;	
	
	unitModels[zombieID].pos.rot = ang;
	unitModels[zombieID].pos.rot %= 360;

	capCoords(unitModels[zombieID].pos);

	updateBlock(zombieID);

	if ( (unitModels[zombieID].pos.x == NaN) || (unitModels[zombieID].pos.y == NaN) || (unitModels[zombieID].pos.rot == NaN) )
	{
		killZombie(zombieID);
		return;
	}

	if (unitModels[zombieID].pos.x <= worldLeft ||
		unitModels[zombieID].pos.x >= worldRight ||
		unitModels[zombieID].pos.y <= worldTop ||
		unitModels[zombieID].pos.y >= worldBottom   )
	{
		unitModels[zombieID].h--;
		if (unitModels[zombieID].h < 0){
			killZombie(zombieID);
			return;
		}
		else 
		{
			sendEveryGeoJ("hurt",{id:zombieID},zombieID);					
		}
	}
	var buf = new Buffer(8);
	buf.writeUInt16LE(parseInt(zombieID),0);
	buf.writeInt16LE(parseInt(unitModels[zombieID].pos.x),2);
	buf.writeInt16LE(parseInt(unitModels[zombieID].pos.y),4);
	buf.writeInt16LE(parseInt(unitModels[zombieID].pos.rot),6);

	sendEveryGeoR('XY',buf,zombieID);


	unitModels[zombieID].rating++;
	checkBite(zombieID,ai.target);
}

function checkBite(zid,pid){
	var biteR = 20;
	if (distSphere(unitModels[zid].pos,unitModels[pid].pos) <= biteR){
		//console.log('BITE ' + pid);
		unitModels[zid].rating+=200;
		connectedPlayers[pid].sendJ("bite",{id:pid, h:unitModels[pid].health});
		sendEveryGeoJ("bite",{id:pid},pid);
		unitModels[pid].health--;
		if (unitModels[pid].health <= 0){	
			connectedPlayers[pid].playerDeath(true);
		}
	}
}

var AITime = 200;

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
	//setTimeout(zombieAIAll,AITime);
	//for (var i in unitModels){
	//	if (unitModels[i] && unitModels[i].type == "zombie") zombieAI(i);
	//}
}

var playerHealth = 100;

function createPlayer(name){
	var id = getfreeID();
	var x = Math.floor(getRandom(-50,50));
	var y = Math.floor(getRandom(-50,50));
	var block = getRealBlock(x,y);
	initBlock(block,id);
	return {type:"human",pos:{x:x,y:y,rot:0},block:block,id:id,lastdx:0,lastdy:0,health:playerHealth,name:name};
}



var s = new obvyazka.Server(handler,"evol");

initSpawns();
zombieAIAll();

function handler(c,a){
	//console.log(JSON.stringify(unitModels));
	var s = "connected: ";
	for (var i in connectedPlayers){
		s+= i;
	}
	console.log(s);

	var playerID = -1;
	c.on("name",function(data){
		if (playerID != -1) return;

		var p = createPlayer(data);
		playerID = p.id;

		console.log("name: " + data);
		console.log("ID: " + playerID);

		unitModels[playerID] = p;
		connectedPlayers[playerID] = c;
		c.sendJ("start",{});
		var unitlist = {};
		for (var i in unitModels){
			if (unitModels[i]){
				var u = unitModels[i];
				unitlist[i] = {type:u.type, pos:u.pos};
				
				if (u.gene)
					unitlist[i].gene = {outfit:u.gene.outfit} ;
				if (u.name)
					unitlist[i].name = u.name ;					
			}
		}
		
		
		c.sendJ("unitlist",unitlist);
		c.sendJ("yourself",playerID);
		sendEveryJ('newunit',unitModels[playerID],playerID);
		console.log("start");

		c.on('XY',function(data){

			unitModels[playerID].lastdx = data.x - unitModels[playerID].pos.x;
			unitModels[playerID].lastdy = data.y - unitModels[playerID].pos.y;
			unitModels[playerID].pos = data;
			
			if (unitModels[playerID].health > 0){
				capCoords(unitModels[playerID].pos);
			}

			updateBlock(playerID);

			if (unitModels[playerID].pos.x <= worldLeft ||
				unitModels[playerID].pos.x >= worldRight ||
				unitModels[playerID].pos.y <= worldTop ||
				unitModels[playerID].pos.y >= worldBottom   )
			{
				if (distCube({x:0,y:0},unitModels[playerID].pos) < 6000){
					console.log("asdasd " + JSON.stringify(unitModels[playerID].pos));
					connectedPlayers[playerID].sendJ("bite",{id:playerID, h:unitModels[playerID].health});
					sendEveryGeoJ("bite",{id:playerID},playerID);
					unitModels[playerID].health-=5;
					if (unitModels[playerID].health <= 0){	
						connectedPlayers[playerID].playerDeath(true);
						return;
					}
				}
			}

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

	c.playerDeath = function(){
		connectedPlayers[playerID].sendJ("yourdeath",{});
		sendEveryGeoJ("death",{id:playerID},playerID);

		unitModels[playerID].lastdx = 0;
		unitModels[playerID].lastdy = 0;
		unitModels[playerID].pos.x = -10000;
		unitModels[playerID].pos.y = -10000;

		updateBlock(playerID);

		var buf = new Buffer(8);
		buf.writeUInt16LE(parseInt(playerID),0);
		buf.writeInt16LE(parseInt(unitModels[playerID].pos.x),2);
		buf.writeInt16LE(parseInt(unitModels[playerID].pos.y),4);
		buf.writeInt16LE(parseInt(unitModels[playerID].pos.rot),6);
		sendEveryGeoR('XY',buf,playerID);
		c.sendR('XY',buf);
	};

	c.on('RE',function(){
		var x = Math.floor(getRandom(-50,50));
		var y = Math.floor(getRandom(-50,50));
		var block = getRealBlock(x,y);
		initBlock(block,playerID);
		unitModels[playerID].pos.x = x;
		unitModels[playerID].pos.y = y;
		unitModels[playerID].block = block;
		unitModels[playerID].health = playerHealth;

		var buf = new Buffer(8);
		buf.writeUInt16LE(parseInt(playerID),0);
		buf.writeInt16LE(parseInt(unitModels[playerID].pos.x),2);
		buf.writeInt16LE(parseInt(unitModels[playerID].pos.y),4);
		buf.writeInt16LE(parseInt(unitModels[playerID].pos.rot),6);
		sendEveryGeoR('XY',buf,playerID);
		c.sendR('XY',buf);
	});

	c.on('close',function(){
		if (playerID === -1) return;


		removeAITarget(playerID);

		sendEveryJ('removeunit',unitModels[playerID],playerID);
		delete blocks[unitModels[playerID].block][playerID];

		delete connectedPlayers[playerID];
		unitModels[playerID] = undefined;

		playerID = -1;
	});
}

s.listen(443);

if (daemonMode)
{
	var pid;

	pid = daemon.start('stdout.log', 'stderr.log');
	daemon.lock('/tmp/crow_game_server.pid');
}