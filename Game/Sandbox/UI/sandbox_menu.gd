extends PanelContainer

@onready var pawn_list: ItemList = %PawnList

var pawnIDs:Array = []

signal onClosePressed

func _ready():
	GameInteractor.pawnRegistry.onPawnListChanged.connect(updatePawnMenu)
	Network.playerListUpdated.connect(updatePawnMenu)
	Network.playerSwitchedCharacter.connect(onPlayerSwitchedCharacter)
	updatePawnMenu()

func onPlayerSwitchedCharacter(_playerID, _oldCharID, _newCharID) -> void:
	updatePawnMenu()

func _on_close_button_pressed() -> void:
	onClosePressed.emit()

func _enter_tree() -> void:
	UIHandler.addUI(self)

func _exit_tree() -> void:
	UIHandler.removeUI(self)

func updatePawnMenu():
	pawn_list.clear()
	pawnIDs.clear()
	
	var _i:int = 0
	for pawnID in GameInteractor.pawnRegistry.pawns:
		var pcInfo:NetworkPlayerInfo = Network.getInfoThatControlsCharID(pawnID)
		var theName:String = str(pawnID)
		if(pcInfo):
			theName += " ("+str(pcInfo.getName())+")"
		
		pawnIDs.append(pawnID)
		var _pawn:CharacterPawn = GameInteractor.pawnRegistry.getPawn(pawnID)
		
		pawn_list.add_item(theName)
		if(pcInfo && pcInfo.isUs()):
			pawn_list.select(_i)
		_i += 1

func _on_switch_button_pressed() -> void:
	if(pawn_list.get_selected_items().is_empty()):
		return
	var theIndx:int = pawn_list.get_selected_items()[0]
	if(theIndx < 0 || theIndx >= pawnIDs.size()):
		return
	var newPawnID:String = pawnIDs[theIndx]
	
	#TODO Make this a gameinteractor thing?
	if(Network.isClient()):
		switchInfoSelectedCharID.rpc_id(1, newPawnID)
		return
	var myInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
	if(!myInfo):
		return
	myInfo.charID = newPawnID

@rpc("any_peer", "call_remote", "reliable")
func switchInfoSelectedCharID(newPawnID:String):
	var myInfo:NetworkPlayerInfo = Network.getPlayerInfo(multiplayer.get_remote_sender_id())
	if(!myInfo):
		return
	myInfo.charID = newPawnID
	
@rpc("any_peer", "call_remote", "reliable")
func _on_add_pawn_button_pressed() -> void:
	if(Network.isClient()):
		_on_add_pawn_button_pressed.rpc_id(1)
		return
	#TODO Make this a gameinteractor thing?
	var thePC:BaseCharacter = GameInteractor.characterRegistry.createCharacter()
	var _thePawn:CharacterPawn = GameInteractor.pawnRegistry.createPawn(thePC.getID())
	_thePawn.position.x = RNG.randfRange(-4.0, 4.0)
	_thePawn.position.z = RNG.randfRange(-2.0, 2.0)

var theCubeScene := preload("res://Game/Multiplayer/NetworkedNode/test_physics_cube.tscn")
func _on_spawn_cube_button_pressed() -> void:
	var cubePos := GM.pcDoll.global_position + Vector3(0.0, 3.0, 0.0)
	if(Network.isClient()):
		spawnCubeOnServer.rpc_id(1, cubePos)
		return
	spawnCubeOnServer(cubePos)

@rpc("any_peer", "call_remote", "reliable")
func spawnCubeOnServer(thePos:Vector3):
	var theCube:Node3D = theCubeScene.instantiate()
	
	GM.game.add_child(theCube, true)
	theCube.global_position = thePos
	GameInteractor.networkedNodes.notifySpawned(theCube)


func _on_spawn_bench_button_pressed() -> void:
	var cubePos := GM.pcDoll.global_position + Vector3(0.0, 0.0, 2.0)
	if(Network.isClient()):
		spawnBenchOnServer.rpc_id(1, cubePos)
		return
	spawnBenchOnServer(cubePos)

var theBenchScene := preload("res://Mapping/Props/bench.tscn")
@rpc("any_peer", "call_remote", "reliable")
func spawnBenchOnServer(thePos:Vector3):
	var theCube:Node3D = theBenchScene.instantiate()
	
	GM.game.add_child(theCube, true)
	theCube.global_position = thePos
	GameInteractor.networkedNodes.notifySpawned(theCube)


func _on_sex_scene_button_pressed() -> void:
	var cubePos := GM.pcDoll.global_position
	var cubeAng := GM.pcDoll.model_root.global_rotation
	if(Network.isClient()):
		spawnSexSceneOnServer.rpc_id(1, cubePos, cubeAng)
		return
	spawnSexSceneOnServer(cubePos, cubeAng)


var theSexScene := preload("res://AnimScenes/Scenes/TestSexAnim/test_sex_handler.tscn")
@rpc("any_peer", "call_remote", "reliable")
func spawnSexSceneOnServer(thePos:Vector3, theAng:Vector3):
	var theCube:Node3D = theSexScene.instantiate()
	
	GM.game.add_child(theCube, true)
	theCube.global_position = thePos
	theCube.global_rotation = theAng
	GameInteractor.networkedNodes.notifySpawned(theCube)

func _on_start_sex_button_pressed() -> void:
	if(pawn_list.get_selected_items().is_empty()):
		return
	var theIndx:int = pawn_list.get_selected_items()[0]
	if(theIndx < 0 || theIndx >= pawnIDs.size()):
		return
	var newPawnID:String = pawnIDs[theIndx]
	
	var pcDoll:DollController = GM.pcDoll
	if(Network.isClient()):
		startSexEngineOnServer.rpc_id(1, pcDoll.getPawn().getCharID(), newPawnID, pcDoll.global_position, pcDoll.model_root.rotation)
		return
	startSexEngineOnServer(pcDoll.getPawn().getCharID(), newPawnID, pcDoll.global_position, pcDoll.model_root.rotation)

@rpc("any_peer", "call_remote", "reliable")
func startSexEngineOnServer(domID:String, subID:String, thePos:Vector3, theAng:Vector3):
	GM.sexManager.startSex(SexType.OnTheFloor, {dom=domID, sub=subID}, {}, thePos, theAng)

func _on_delete_pawn_button_pressed() -> void:
	if(pawn_list.get_selected_items().is_empty()):
		return
	var theIndx:int = pawn_list.get_selected_items()[0]
	if(theIndx < 0 || theIndx >= pawnIDs.size()):
		return
	var deletePawnID:String = pawnIDs[theIndx]
	
	if(Network.isClient()):
		deleteCharIDOnServer.rpc_id(1, deletePawnID)
		return
	deleteCharIDOnServer(deletePawnID)

@rpc("any_peer", "call_remote", "reliable")
func deleteCharIDOnServer(deletePawnID:String):
	GM.pawnRegistry.deletePawn(deletePawnID)
	GM.characterRegistry.removeCharacterID(deletePawnID)
