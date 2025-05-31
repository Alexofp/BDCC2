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

func startSex(sexTypeID:String, pawns:Dictionary, args:Dictionary, thePos:Vector3, theAng:Vector3) -> SexEngine:
	if(!checkPawnsInternal(pawns)):
		Log.Printerr("Invalid characters setup, can't start sex: "+str(pawns))
		return null
	for charID in pawns.values():
		stopAnySexWithCharIDInvolved(charID)
	var newSexEngine:SexEngine = sexEngineScene.instantiate()
	add_child(newSexEngine, true)
	newSexEngine.global_position = thePos
	newSexEngine.global_rotation = theAng
	#sexEngines.append(newSexEngine)
	
	for role in pawns:
		var charID:String = pawns[role]
		newSexEngine.addParticipant(charID, SexEngine.ROLE_SWITCH)
		
	newSexEngine.start(sexTypeID, pawns, args)
	
	#GameInteractor.networkedNodes.notifySpawned(newSexEngine)
	
	
	return newSexEngine

func checkPawnsInternal(pawns:Dictionary) -> bool:
	var uniqueCharIDs:Array = []
	
	for role in pawns:
		var theCharID:String = pawns[role]
		
		if(!GM.pawnRegistry.hasPawn(theCharID)):
			return false
		if(uniqueCharIDs.has(theCharID)):
			return false
		uniqueCharIDs.append(theCharID)
	
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

func saveNetworkData() -> Dictionary:
	return {}

func loadNetworkData(_data:Dictionary):
	#sexEngines.clear()
	pass
