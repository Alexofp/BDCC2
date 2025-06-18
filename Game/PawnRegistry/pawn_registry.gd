extends Node3D
class_name PawnRegistry

var pawnScene := preload("res://Game/PawnRegistry/character_pawn.tscn")

var pawns:Dictionary[String, CharacterPawn] = {}

signal onPawnCreated(pawn)
signal onPawnDeleted(pawn)
signal onPawnListChanged

const GRID_SIZE = 10
var sparsePawnGrid:Dictionary[Vector2i, Array] = {}

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
	
	insertPawnIntoSparseGrid(thePawn)
	onPawnCreated.emit(thePawn)
	onPawnListChanged.emit()

@rpc("authority", "call_remote", "reliable")
func deletePawnRPC(charID:String):
	if(!hasPawn(charID)):
		assert(false, "Pawn doesn't exist")
		return
	pawns[charID].queue_free()

#TODO: Ability to spawn at specific position?
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
	
	insertPawnIntoSparseGrid(thePawn)
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
	onPawnDeleted.emit(thePawn) # Should this happen after the erase?
	
	if(thePawn.is_inside_tree()):
		thePawn.name = "TO_BE_DELETED"
	pawns.erase(thePawn.id)
	
	removePawnFromSparseGridSpecific(thePawn, thePawn.gridPos)
	
	onPawnListChanged.emit()

func clearPawns():
	for charID in pawns.keys():
		pawns[charID].queue_free()
	pawns = {}

func shouldPawnDollBeSpawned(_thePawn:CharacterPawn) -> bool:
	for playerID in Network.players:
		var info:NetworkPlayerInfo = Network.players[playerID]
		if(info.charID != ""):
			# If we are the player
			if(info.charID == _thePawn.id):
				return true
			# if any player is nearby
			var thePCPawn:CharacterPawn = getPawn(info.charID)
			if(thePCPawn && thePCPawn.global_position.distance_squared_to(_thePawn.global_position) < 30.0):
				return true
	
	return false

func deletePawnOfNetworkPlayer(info:NetworkPlayerInfo):
	if(info.charID == ""):
		return
	deletePawn(info.charID)

#TODO: Make this use a grid or whatever
func getPawnsNear(_pos:Vector3, _radius:float) -> Array[CharacterPawn]:
	var result:Array[CharacterPawn] = []
	var _radSquared:float = _radius * _radius
	
	for charID in pawns:
		var thePawn:CharacterPawn = pawns[charID]
		if(thePawn.global_position.distance_squared_to(_pos) <= _radSquared):
			result.append(thePawn)
	
	return result

func getGridPos(_pos:Vector3) -> Vector2i:
	return Vector2i(round(_pos.x/GRID_SIZE), round(_pos.z/GRID_SIZE))

func insertPawnIntoSparseGrid(_pawn:CharacterPawn):
	var thePos:Vector3 = _pawn.global_position
	var theGridPos := getGridPos(thePos)
	insertPawnIntoSparseGridSpecific(_pawn, theGridPos)
	
func insertPawnIntoSparseGridSpecific(_pawn:CharacterPawn, theGridPos:Vector2i):
	if(!sparsePawnGrid.has(theGridPos)):
		sparsePawnGrid[theGridPos] = [_pawn]
	else:
		sparsePawnGrid[theGridPos].append(_pawn)
	_pawn.gridPos = theGridPos

func removePawnFromSparseGridSpecific(_pawn:CharacterPawn, _pos:Vector2i):
	if(!sparsePawnGrid.has(_pos)):
		return
	sparsePawnGrid[_pos].erase(_pawn)

func checkPawnSparseGrid(_pawn:CharacterPawn):
	var thePos:Vector3 = _pawn.global_position
	var theGridPos := getGridPos(thePos)
	
	if(_pawn.gridPos != theGridPos):
		removePawnFromSparseGridSpecific(_pawn, _pawn.gridPos)
		insertPawnIntoSparseGridSpecific(_pawn, theGridPos)

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
