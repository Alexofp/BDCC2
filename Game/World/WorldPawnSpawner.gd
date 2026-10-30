extends RefCounted
class_name WorldPawnSpawner

const PawnSleepCD:float = 30.0
const PawnGoToSleepAfter:float = 300.0

var nextSpawnTime:float = 3.0
var spawnCD:Dictionary[String, float] # dict[charID, howMuchTime]

func spawnWave(_shareMin:float = 0.5, _shareMax:float = 0.8, _countCurrent:bool = true):
	var theShare:float = RNG.randfRange(_shareMin, _shareMax)
	var theAm:int = int(ceilf(float(getPawnPop())*theShare))
	
	if(_countCurrent):
		theAm -= getCurrentPawnCount()
	
	if(theAm <= 0):
		return
	for _i:int in theAm:
		trySpawnPawn()

func getPawnPop() -> int:
	return GM.characterRegistry.characterList.size() - GM.game.playersData.size()

func getCurrentPawnCount() -> int:
	# Should probably check if those network players have a pawn assigned to them but ehh
	return GM.pawnRegistry.pawnList.size() - Network.players.size()

func getPawnPopFullness() -> float:
	var totalPop:int = getPawnPop()
	var currentPop:int = getCurrentPawnCount()
	if(totalPop <= 0):
		return 1.0
	if(currentPop <= 0):
		return 0.0
	if(currentPop > totalPop):
		return 1.0
	return float(currentPop) / float(totalPop)

var toRem:Array[String]
func processSpawner(_dt:float):
	if(!Network.isServer()):
		return
	nextSpawnTime -= _dt
	if(nextSpawnTime <= 0.0):
		var theFullness:float = getPawnPopFullness()
		if(theFullness < 0.5):
			nextSpawnTime = RNG.randfRange(5.0, 15.0)
		elif(theFullness < 0.7):
			nextSpawnTime = RNG.randfRange(15.0, 30.0)
		elif(theFullness < 0.9):
			nextSpawnTime = RNG.randfRange(30.0, 120.0)
		else:
			nextSpawnTime = RNG.randfRange(120.0, 300.0)
		
		trySpawnPawn()
	
	toRem.clear()
	for _charID:String in spawnCD:
		spawnCD[_charID] -= _dt
		if(spawnCD[_charID] <= 0.0):
			toRem.append(_charID)
	for _charID:String in toRem:
		spawnCD.erase(_charID)

func trySpawnPawn() -> bool:
	var theChars:Array[BaseCharacter] = getCharactersCanSpawn()
	if(theChars.is_empty()):
		return false
	var theChar:BaseCharacter = RNG.pick(theChars)
	
	var theSpawnPoint:InmateSpawnPoint = GM.main.world.getRandomInmateSpawn()
	if(!theSpawnPoint):
		return false
	
	var thePawn:CharacterPawn = GM.main.pawn_registry.createPawn(theChar.getID())
	if(!thePawn):
		return false
	thePawn.global_position = theSpawnPoint.global_position + Vector3(RNG.randfRange(-0.1, 0.1), 0.0, RNG.randfRange(-0.1, 0.1))
	
	return true

func getCharactersCanSpawn() -> Array[BaseCharacter]:
	var result:Array[BaseCharacter]
	
	for theChar:BaseCharacter in GM.main.characterRegistry.characterList:
		var theID:String = theChar.getID()
		if(spawnCD.has(theID)):
			continue
		if(GM.main.pawn_registry.hasPawn(theID)):
			continue
		if(GM.main.doesCharIDHavePlayerData(theID)): # No spawning chars that belong to players
			continue
		# Check how much time has passed since they went away last time?
		result.append(theChar)
	
	return result

func onPawnWentHome(_pawn:CharacterPawn):
	if(!_pawn):
		return
	spawnCD[_pawn.getID()] = PawnSleepCD
	var theFullness:float = getPawnPopFullness()
	if(theFullness < 0.5):
		nextSpawnTime = minf(RNG.randfRange(5.0, 15.0), nextSpawnTime)
	elif(theFullness < 0.7):
		nextSpawnTime = minf(RNG.randfRange(15.0, 30.0), nextSpawnTime)

func saveData() -> Dictionary:
	return {
		spawnCD = spawnCD,
		nst = nextSpawnTime,
	}

func loadData(_data:Dictionary):
	spawnCD.clear()
	spawnCD.merge(SAVE.loadDict(_data, "spawnCD"))
	nextSpawnTime = SAVE.loadFloat(_data, "nst", 3.0)
