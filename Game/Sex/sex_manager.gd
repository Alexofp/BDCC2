extends Node3D
class_name SexManager

var sexEngines:Array[SexEngine] = []

var sexEngineScene := preload("res://Game/Sex/SexEngine.tscn")

func _init() -> void:
	GI.sexManager = self

func addSexInternal(theNode:SexEngine):
	if(sexEngines.has(theNode)):
		assert(false, "Trying to add the same sex engine twice!")
		return
	sexEngines.append(theNode)

func removeSexInternal(theNode:SexEngine):
	sexEngines.erase(theNode)

#func startSex(sexTypeID:String, roles:Dictionary, args:Dictionary, thePos:Vector3, theAng:Vector3) -> SexEngine:
func startSex(_conf:SexStartConf) -> SexEngine:
	if(!_conf):
		Log.Printerr("Sex start confing is null!")
		return null
	if(!checkPawnsInternal(_conf.roles)):
		Log.Printerr("Invalid characters setup, can't start sex: "+str(_conf.roles))
		return null
	for theRole in _conf.roles:
		var theInfo:Dictionary = _conf.roles[theRole]
		if(theInfo.has("id")):
			stopAnySexWithCharIDInvolved(theInfo["id"])
	var newSexEngine:SexEngine = sexEngineScene.instantiate()
	add_child(newSexEngine, true)
	newSexEngine.global_position = _conf.pos
	newSexEngine.global_rotation = _conf.ang
	#sexEngines.append(newSexEngine)
	
	var roleToID:Dictionary[String, String] = {}
	
	for role in _conf.roles:
		var theInfo:Dictionary = _conf.roles[role]
		var newParticipant:SexParticipantInfo = SexParticipantInfo.new()
		newParticipant.setSexEngine(newSexEngine)
		if(newParticipant.setupInfo(theInfo)):
			newSexEngine.addParticipantInfo(newParticipant)
			roleToID[role] = newParticipant.id
		else:
			newSexEngine.stopSex()
			return null
	
	for propID in _conf.props:
		var theNode:Node3D = _conf.props[propID]
		newSexEngine.addProp(propID, theNode)
	
	newSexEngine.start(_conf.sexType, roleToID, _conf.args)
	
	#GI.networkedNodes.notifySpawned(newSexEngine)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(spawnSexEngine_RPC.bind(newSexEngine.saveData()))
	return newSexEngine

@rpc("authority", "call_remote", "reliable")
func spawnSexEngine_RPC(theEntry:Dictionary):
	var newSexEngine:SexEngine = sexEngineScene.instantiate()
	newSexEngine.name = SAVE.loadStr(theEntry, "name", "borke")
	add_child(newSexEngine, true)
	newSexEngine.loadData(theEntry)
	#if(newSexEngine.shouldBeRemoved):
	#	newSexEngine.name += "_FAILED_TO_LOAD"
	#	newSexEngine.queue_free()

func checkPawnsInternal(pawns:Dictionary) -> bool:
	var uniqueCharIDs:Array = []
	
	for role in pawns:
		if(!(pawns[role] is Dictionary)):
			return false
		var theInfo:Dictionary = pawns[role]
		if(theInfo.has("id")):
			var theCharID:String = theInfo["id"]
			
			if(!GM.pawnRegistry.hasPawn(theCharID)):
				return false
			if(uniqueCharIDs.has(theCharID)):
				return false
			uniqueCharIDs.append(theCharID)
		else:
			return false
	
	return true

func getSexEngineOfPawn(thePawn:CharacterPawn) -> SexEngine:
	for sexEngine in sexEngines:
		if(sexEngine.isPawnInvolved(thePawn)):
			return sexEngine
	
	return null

# Could be optimized with a pawnToSexEngine dict?
func getSexEngineOfCharID(theCharID:String) -> SexEngine:
	for sexEngine in sexEngines:
		if(sexEngine.isCharIDInvolved(theCharID)):
			return sexEngine
	
	return null

func stopAnySexWithCharIDInvolved(theCharID:String):
	var sexAmount:int = sexEngines.size()
	for _i in range(sexAmount):
		var sexEngine:SexEngine = sexEngines[sexAmount-_i-1]
		if(sexEngine.isCharIDInvolved(theCharID)):
			sexEngine.stopSex()

func isParticipatingInSex(thePawn:CharacterPawn) -> bool:
	return !!getSexEngineOfPawn(thePawn)

func isCharIDParticipatingInSex(theCharID:String) -> bool:
	return !!getSexEngineOfCharID(theCharID)
	
func isCharParticipatingInSex(theChar:BaseCharacter) -> bool:
	return !!getSexEngineOfCharID(theChar.getID())

func askStartMasturbation(_charID:String):
	if(Network.isClient()):
		askStartMasturbation_SERVERRPC.rpc_id(1, _charID)
	else:
		askStartMasturbation_SERVERRPC(_charID)

func canStartMasturbation(_pawn:CharacterPawn) -> bool:
	if(GM.sitManager.isSitting(_pawn)):
		return false
	if(_pawn.isInCombatMode()):
		return false
	if(_pawn.isDoingSomething()):
		return false
	if(_pawn.isDoingSex()):
		return false
	if(_pawn.isLeashedByAnyone()): # To prevent them from freezing themselves in place?
		return false
	if(_pawn.isDominatedByAnyone()): # Maybe the dom should be able to order the sub to masturbate
		return false
	
	return true

@rpc("any_peer", "call_remote", "reliable")
func askStartMasturbation_SERVERRPC(_pawnID:String):
	var thePawn := GM.pawnRegistry.getPawn(_pawnID)
	if(!thePawn):
		return
	if(!canStartMasturbation(thePawn)):
		return
	var newSex := SexStartConf.new()
	newSex.sexType = SexType.Solo
	newSex.addRole("dom", _pawnID, SexRole.Dom)
	newSex.pos = thePawn.global_position
	newSex.ang = thePawn.global_rotation
	startSex(newSex)

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.Var, saveData(),
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	loadData(_data.readVar())
	_data.endLoad()

func saveData() -> Dictionary:
	var sexDatas:Array[Dictionary]
	for theSexEngine:SexEngine in sexEngines:
		sexDatas.append(theSexEngine.saveData())
	
	return {
		sexEngines = sexDatas,
	}

func loadData(_data:Dictionary):
	for theSexEngine:SexEngine in sexEngines.duplicate():
		theSexEngine.queue_free()
		theSexEngine.name += "_DELETED"
	sexEngines.clear()
	
	var sexDatas:Array[Dictionary] = SAVE.loadArrayOfDicts(_data, "sexEngines")
	for theEntry:Dictionary in sexDatas:
		var newSexEngine:SexEngine = sexEngineScene.instantiate()
		newSexEngine.name = SAVE.loadStr(theEntry, "name", "borke")
		add_child(newSexEngine, true)
		newSexEngine.loadData(theEntry)
		if(newSexEngine.shouldBeRemoved):
			newSexEngine.name += "_FAILED_TO_LOAD"
			newSexEngine.queue_free()
			continue
		
