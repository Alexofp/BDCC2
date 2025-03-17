extends Node3D
class_name PawnRegistry

var pawnScene := preload("res://Game/PawnRegistry/character_pawn.tscn")

var pawns:Dictionary[String, CharacterPawn] = {}

signal onPawnCreated(pawn)
signal onPawnDeleted(pawn)
signal onPawnListChanged

func _ready() -> void:
	GameInteractor.pawnRegistry = self
	pass

func hasPawn(charID:String) -> bool:
	return pawns.has(charID)

@rpc("authority", "call_remote", "reliable")
func createPawnRPC(charID:String, data:Dictionary):
	Log.Print("CREATEPAWN_RPC "+str(charID)+" "+str(data))
	var thePawn:CharacterPawn= pawnScene.instantiate()
	thePawn.name = charID
	thePawn.id = charID
	pawns[thePawn.id] = thePawn
	
	thePawn.tree_exiting.connect(pawnDeleteCleanup.bind(thePawn))
	
	add_child(thePawn, true)
	thePawn.loadNetworkData(data)
	onPawnCreated.emit(thePawn)
	onPawnListChanged.emit()

@rpc("authority", "call_remote", "reliable")
func deletePawnRPC(charID:String):
	if(!hasPawn(charID)):
		assert(false, "Pawn doesn't exist")
		return
	pawns[charID].queue_free()

func createPawn(charID:String) -> CharacterPawn:
	if(!Network.isServer()):
		return null
	if(hasPawn(charID)):
		assert(false, "Pawn already exists")
		return null
	
	var _character:BaseCharacter = GM.characterRegistry.getCharacter(charID)
	var thePawn:CharacterPawn= pawnScene.instantiate()
	thePawn.name = charID
	thePawn.id = charID
	pawns[thePawn.id] = thePawn
	
	thePawn.tree_exiting.connect(pawnDeleteCleanup.bind(thePawn))
	
	add_child(thePawn, true)
	
	onPawnCreated.emit(thePawn)
	onPawnListChanged.emit()
	
	if(Network.isServerNotSingleplayer()):
		createPawnRPC.rpc(charID, thePawn.saveNetworkData())
	
	return thePawn

func getPawn(charID:String) -> CharacterPawn:
	if(!pawns.has(charID)):
		return null
	return pawns[charID]

func deletePawn(charID:String):
	if(!Network.isServer()):
		return null
	if(!hasPawn(charID)):
		assert(false, "Pawn doesn't exist")
		return
	pawns[charID].queue_free()
	pawns.erase(charID)

	if(Network.isServerNotSingleplayer()):
		deletePawnRPC.rpc(charID)

func pawnDeleteCleanup(thePawn:CharacterPawn):
	onPawnDeleted.emit(thePawn)
	onPawnListChanged.emit()
	
	if(thePawn.is_inside_tree()):
		thePawn.name = "TO_BE_DELETED"
	pawns.erase(thePawn.id)

func clearPawns():
	for charID in pawns.keys():
		pawns[charID].queue_free()
	pawns = {}

func shouldPawnDollBeSpawned(_thePawn:CharacterPawn) -> bool:
	return true

func deletePawnOfNetworkPlayer(info:NetworkPlayerInfo):
	if(info.charID == ""):
		return
	deletePawn(info.charID)

func saveNetworkData() -> Dictionary:
	var pawnData:Array = []
	for charID in pawns:
		pawnData.append({
			id = charID,
			data = pawns[charID].saveNetworkData(),
		})
	
	return {
		pawns = pawnData,
	}

func loadNetworkData(_data:Dictionary):
	clearPawns()
	
	Log.Print(str(_data))
	var pawnData:Array = SAVE.loadVar(_data, "pawns", [])
	for pawnEntry in pawnData:
		createPawnRPC(SAVE.loadVar(pawnEntry, "id", ""), SAVE.loadVar(pawnEntry, "data", {}))
