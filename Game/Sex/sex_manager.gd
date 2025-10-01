extends Node3D
class_name SexManager

var sexEngines:Array[SexEngine] = []

var sexEngineScene := preload("res://Game/Sex/SexEngine.tscn")

func _init() -> void:
	GameInteractor.sexManager = self

func addSexInternal(theNode:SexEngine):
	sexEngines.append(theNode)

func removeSexInternal(theNode:SexEngine):
	sexEngines.erase(theNode)

func startSex(sexTypeID:String, roles:Dictionary, args:Dictionary, thePos:Vector3, theAng:Vector3) -> SexEngine:
	if(!checkPawnsInternal(roles)):
		Log.Printerr("Invalid characters setup, can't start sex: "+str(roles))
		return null
	for theRole in roles:
		var theInfo:Dictionary = roles[theRole]
		if(theInfo.has("id")):
			stopAnySexWithCharIDInvolved(theInfo["id"])
	var newSexEngine:SexEngine = sexEngineScene.instantiate()
	add_child(newSexEngine, true)
	newSexEngine.global_position = thePos
	newSexEngine.global_rotation = theAng
	#sexEngines.append(newSexEngine)
	
	var roleToID:Dictionary[String, String] = {}
	
	for role in roles:
		var theInfo:Dictionary = roles[role]
		var newParticipant:SexParticipantInfo = SexParticipantInfo.new()
		newParticipant.setSexEngine(newSexEngine)
		if(newParticipant.setupInfo(theInfo)):
			newSexEngine.addParticipantInfo(newParticipant)
			roleToID[role] = newParticipant.id
		else:
			newSexEngine.stopSex()
			return null

	newSexEngine.start(sexTypeID, roleToID, args)
	
	#GameInteractor.networkedNodes.notifySpawned(newSexEngine)
	
	return newSexEngine

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

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd()

func loadNetworkData(_data:Bins):
	_data.loadStart()
	
	_data.endLoad()

func saveData() -> Dictionary:
	return {}

func loadData(_data:Dictionary):
	#sexEngines.clear()
	pass
