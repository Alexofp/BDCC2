extends Node3D
class_name DollHolder
@onready var dolls: Node3D = %Dolls
#@onready var multiplayer_spawner: MultiplayerSpawner = %MultiplayerSpawner

var dollControllerScene := preload("res://Game/DollController/doll_controller.tscn")

var lastUniqueID:int = 0

var dollList:Array[DollController]
var uidToDoll:Dictionary[int, DollController]
var charIDToDoll:Dictionary[String, DollController]

var curDoll:DollController
signal onCurrentDollSwitch(oldDoll, newDoll)

func addDollToLists(_doll:DollController):
	dollList.append(_doll)
	uidToDoll[_doll.uniqueID] = _doll
	charIDToDoll[_doll.getCharacter().getID()] = _doll

func removeDollFromLists(_doll:DollController):
	dollList.erase(_doll)
	uidToDoll.erase(_doll.uniqueID)
	charIDToDoll.erase(_doll.getCharacter().getID())

func _ready() -> void:
	GI.dollHolder = self
	
	Network.playerSwitchedCharacter.connect(onAnyPlayerSwitchCharacter)

func onAnyPlayerSwitchCharacter(_pid:int, _oldCharID:String, _newCharID:String):
	var theOldDoll := findDollByCharID(_oldCharID)
	var theNewDoll := findDollByCharID(_newCharID)
	if(theOldDoll):
		theOldDoll.processFocus()
	if(theNewDoll):
		theNewDoll.processFocus()
	
	checkCurrentDoll()

func findDollByCharID(_charID:String) -> DollController:
	if(!GM.pawnRegistry):
		return null
	var thePawn := GM.pawnRegistry.getPawn(_charID)
	return thePawn.getDoll() if thePawn else null

func generateUniqueDollID() -> int:
	lastUniqueID += 1
	while(findDollWithUniqueID(lastUniqueID)):
		lastUniqueID += 1
	return lastUniqueID
	
func createDollControllerForPawn(pawn:CharacterPawn) -> DollController:
	var theDoll := createDollControllerFor(pawn, pawn.getCharacter())
	theDoll.position = pawn.position
	return theDoll
	
func createDollControllerFor(pawn:CharacterPawn, character:BaseCharacter) -> DollController:
	if(!Network.isServer()):
		return null
	Log.Print("createDollControllerFor "+str(character.getID()))
	var newUniqueID:int = generateUniqueDollID()
	var theDoll:DollController= dollControllerScene.instantiate()
	#theDoll.position = Vector3(99312.0, 12312.0, -3134.0)
	theDoll.charID = pawn.getID()
	theDoll.pawn = pawn
	theDoll.uniqueID = newUniqueID
	addExistingDollController(theDoll)
	return theDoll

func onDollDeleted(doll:DollController):
	if(doll.is_inside_tree()):
		doll.name += "_DELETED"
	removeDollFromLists(doll)
	doll.pawn.notifyDollDespawned(doll)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(deleteDoll_RPC.bind(doll.uniqueID))

@rpc("authority", "call_remote", "reliable")
func deleteDoll_RPC(uniqueID:int):
	var theDoll:DollController = findDollWithUniqueID(uniqueID)
	if(!theDoll):
		Log.Printerr("Couldn't find a doll to delete with ID "+str(uniqueID))
		return
	theDoll.queue_free()

@rpc("authority", "call_remote", "reliable")
func createDollController_RPC(dollData:Dictionary):
	var theDoll:DollController= dollControllerScene.instantiate()
	theDoll.position = Vector3(99312.0, 12312.0, -3134.0) # So they don't collide with anything
	theDoll.charID = SAVE.loadVar(dollData, "charID", "")
	theDoll.pawn = GM.pawnRegistry.getPawn(theDoll.charID)
	theDoll.uniqueID = SAVE.loadVar(dollData, "UID", theDoll.uniqueID)
	addExistingDollController(theDoll)

# Doll must have:
# uniqueID defined
# charID defined
# pawn defined
func addExistingDollController(theDoll:DollController):
	Log.Print("Adding doll for UID="+str(theDoll.uniqueID))
	theDoll.name = str(theDoll.uniqueID)
	theDoll.tree_exiting.connect(onDollDeleted.bind(theDoll))
	#theDoll.pawn = GM.pawnRegistry.getPawn(SAVE.loadVar(dollData, "charID", ""))
	#theDoll.uniqueID = SAVE.loadVar(dollData, "UID", theDoll.uniqueID)
	dolls.add_child(theDoll)
	#theDoll.loadData(dollData)
	addDollToLists(theDoll)
	theDoll.afterAddedToDollHolder()
	theDoll.pawn.notifyDollSpawned(theDoll)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(createDollController_RPC.bind(theDoll.saveData()))

func clearDolls():
	Util.delete_children(dolls)
	dollList.clear()
	uidToDoll.clear()
	charIDToDoll.clear()
	
func deleteDoll(theDoll:DollController):
	theDoll.queue_free()

func deleteDollsOfNetworkPlayerID(clientID:int):
	var toRemove:Array[DollController] = []
	for doll:DollController in dollList:
		if(!(doll is DollController)):
			continue
		if(doll.networkPlayerID == clientID):
			toRemove.append(doll)
	for doll in toRemove:
		doll.queue_free()

func findDollWithUniqueID(theID:int) -> DollController:
	if(!uidToDoll.has(theID)):
		return null
	return uidToDoll[theID]

func checkOutOfBoundsCharacters(_lowPoint:float = -200.0, _resetPoint:Vector3 = Vector3(0.0, 0.0, 0.0)):
	for doll:DollController in dollList:
		if(!(doll is DollController)):
			continue
		if(doll is DollController):
			if(doll.global_position.y < _lowPoint):
				doll.global_position = _resetPoint

func _process(_delta: float) -> void:
	checkCurrentDoll()
	pass

func checkCurrentDoll():
	var curCharID:String = Network.getMyCharID()
	var thePawn := GM.pawnRegistry.getPawn(curCharID) if GM.pawnRegistry else null
	var theDoll := thePawn.getDoll() if thePawn else null
	
	if(theDoll != curDoll):
		notifyCurrentDollSwitch(theDoll)

func notifyCurrentDollSwitch(_newDoll:DollController):
	if(_newDoll == curDoll):
		return
	var oldDoll:DollController=curDoll

	if(oldDoll):
		oldDoll.processFocus()
	curDoll = _newDoll
	if(curDoll):
		curDoll.processFocus()
	onCurrentDollSwitch.emit(oldDoll, curDoll)

func saveNetworkData() -> Bins:
	var Ar:Array = [
		Bins.U16, dollList.size(),
	]
	for theDoll:DollController in dollList:
		Ar.append_array([
			Bins.BINS, theDoll.saveNetworkData(),
		])
	
	return Bins.saveStartEnd(Ar)

func loadNetworkData(_data:Bins):
	_data.loadStart()
	clearDolls()
	
	var _dollAm:int = _data.readU16()
	for _i:int in _dollAm:
		var theDoll:DollController = dollControllerScene.instantiate()
		theDoll.position = Vector3(99312.0, 12312.0, -3134.0)
		theDoll.loadNetworkData(_data.readBins())
		addExistingDollController(theDoll)
	
	loadData(_data.readVar())
	_data.endLoad()

func saveData() -> Dictionary:
	var dollData:Array = []
	
	for doll:DollController in dollList:
		dollData.append(doll.saveData())
	
	return {
		dolls = dollData,
		lastUniqueID = lastUniqueID,
	}

func loadData(_data:Dictionary):
	clearDolls()
	
	var dollData:Array = SAVE.loadVar(_data, "dolls", [])
	for dollEntry in dollData:
		var theDoll:DollController = dollControllerScene.instantiate()
		theDoll.position = Vector3(99312.0, 12312.0, -3134.0)
		theDoll.loadData(dollEntry)
		addExistingDollController(theDoll)
		#createDollController_RPC(dollEntry)
	lastUniqueID = SAVE.loadVar(_data, "lastUniqueID", 0)

@rpc("authority", "call_remote", "reliable")
func playGesture_RPC(theDollID:int, _gestureID:String):
	var theDoll:= findDollWithUniqueID(theDollID)
	if(!theDoll):
		return
	
	var shouldFullBody:bool = true
	var shouldPartial:bool = true
	
	var thePawn := theDoll.getPawn()
	if(thePawn):
		shouldFullBody = !thePawn.poseHandler.gestureFullbodyBlocked
		shouldPartial = !thePawn.poseHandler.gesturePartialBlocked
	
	theDoll.getDoll().playGesture(_gestureID, shouldFullBody, shouldPartial)

func playGesture(_doll:DollController, _gestureID:String):
	if(Network.isClient()):
		return
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(playGesture_RPC.bind(_doll.uniqueID, _gestureID))
	playGesture_RPC(_doll.uniqueID, _gestureID)

@rpc("any_peer", "call_remote", "reliable")
func askPlayGesture_SERVERRPC(theDollID:int, _gestureID:String):
	# Any checks should go here
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(playGesture_RPC.bind(theDollID, _gestureID))
	playGesture_RPC(theDollID, _gestureID)
	#var theDoll:= findDollWithUniqueID(theDollID)
	#if(!theDoll):
		#return
	#theDoll.getDoll().playGesture(_gestureID)

func askPlayGesture(_doll:DollController, _gestureID:String):
	if(Network.isServer()):
		playGesture(_doll, _gestureID)
	else:
		askPlayGesture_SERVERRPC.rpc_id(1, _doll.uniqueID, _gestureID)

func askLookAtCustom(_doll:DollController, _pos:Vector3):
	if(!_doll):
		return
	if(Network.isServer()):
		_doll.getDoll().lookAtCustom(_pos)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(askLookAtCustom_RPC.bind(_doll.uniqueID, _pos))
	elif(Network.isClient()):
		askLookAtCustom_ServerRPC.rpc_id(1, _doll.uniqueID, _pos)

@rpc("authority", "call_remote", "reliable")
func askLookAtCustom_RPC(dollUniqueID:int, _pos:Vector3):
	var theDoll := findDollWithUniqueID(dollUniqueID)
	if(!theDoll):
		return
	theDoll.getDoll().lookAtCustom(_pos)

@rpc("any_peer", "call_remote", "reliable")
func askLookAtCustom_ServerRPC(dollUniqueID:int, _pos:Vector3):
	var theDoll := findDollWithUniqueID(dollUniqueID)
	if(!theDoll):
		return
	askLookAtCustom(theDoll, _pos)

func askLookAtClear(_doll:DollController):
	if(!_doll):
		return
	if(Network.isServer()):
		_doll.getDoll().lookAtClear()
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(askLookAtClear_RPC.bind(_doll.uniqueID))
	elif(Network.isClient()):
		askLookAtClear_ServerRPC.rpc_id(1, _doll.uniqueID)

@rpc("authority", "call_remote", "reliable")
func askLookAtClear_RPC(dollUniqueID:int):
	var theDoll := findDollWithUniqueID(dollUniqueID)
	if(!theDoll):
		return
	theDoll.getDoll().lookAtClear()

@rpc("any_peer", "call_remote", "reliable")
func askLookAtClear_ServerRPC(dollUniqueID:int):
	var theDoll := findDollWithUniqueID(dollUniqueID)
	if(!theDoll):
		return
	askLookAtClear(theDoll)


func askLookAtDoll(_doll:DollController, _doll2:DollController, _howLong:float = 5.0):
	if(!_doll):
		return
	
	if(!_doll2):
		askLookAt(_doll, null, _howLong)
	else:
		askLookAt(_doll, _doll2.getDoll().getEyesNode(), _howLong)

func askLookAt(_doll:DollController, _node:Node3D, _howLong:float = 10.0):
	if(!_doll):
		return
	if(Network.isServer()):
		_doll.getDoll().lookAt(_node, _howLong)
	if(Network.isServerNotSingleplayer()):
		var theNode = GI.getUniqueIDOf(_node)
		Network.rpcClients(askLookAt_RPC.bind(_doll.uniqueID, theNode, _howLong))
	elif(Network.isClient()):
		var theNode = GI.getUniqueIDOf(_node)
		askLookAt_ServerRPC.rpc_id(1, _doll.uniqueID, theNode, _howLong)

@rpc("authority", "call_remote", "reliable")
func askLookAt_RPC(dollUniqueID:int, _nodeData, _howLong:float):
	var theDoll := findDollWithUniqueID(dollUniqueID)
	if(!theDoll):
		return
	var theNode = GI.getNodeByUniqueID(_nodeData)
	if(!theNode):
		return
	theDoll.getDoll().lookAt(theNode, _howLong)

@rpc("any_peer", "call_remote", "reliable")
func askLookAt_ServerRPC(dollUniqueID:int, _nodeData, _howLong:float):
	var theDoll := findDollWithUniqueID(dollUniqueID)
	if(!theDoll):
		return
	var theNode = GI.getNodeByUniqueID(_nodeData)
	if(!theNode):
		return
	askLookAt(theDoll, theNode, _howLong)

func applyHitRandom(_doll:DollController, _strength:float):
	if(!_doll):
		return
	_doll.applyHitRandom(_strength)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(applyHitRandom_RPC.bind(_doll.uniqueID, _strength))

@rpc("authority", "call_remote", "reliable")
func applyHitRandom_RPC(dollUniqueID:int, _strength:float):
	var theDoll := findDollWithUniqueID(dollUniqueID)
	if(!theDoll):
		return
	theDoll.applyHitRandom(_strength)
