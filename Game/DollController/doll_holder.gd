extends Node3D
class_name DollHolder
@onready var dolls: Node3D = %Dolls
#@onready var multiplayer_spawner: MultiplayerSpawner = %MultiplayerSpawner

var dollControllerScene := preload("res://Game/DollController/doll_controller.tscn")

var curDoll:DollController
signal onCurrentDollSwitch(oldDoll, newDoll)

func _ready() -> void:
	GameInteractor.dollHolder = self

var lastUniqueID:int = 0
func generateUniqueDollID() -> int:
	lastUniqueID += 1
	return lastUniqueID
	
func createDollControllerForPawn(pawn:CharacterPawn) -> DollController:
	var theDoll := createDollControllerFor(pawn.getCharacter())
	theDoll.position = pawn.position
	return theDoll
	
func createDollControllerFor(character:BaseCharacter) -> DollController:
	if(Network.isServer()):
		Log.Print("createDollControllerFor "+str(character.getID()))
		
		var newUniqueID:int = generateUniqueDollID()
		var theDoll:DollController= dollControllerScene.instantiate()
		theDoll.name = str(newUniqueID)
		theDoll.characterID = character.getID()
		theDoll.uniqueID = newUniqueID
		theDoll.tree_exiting.connect(onDollDeleted.bind(theDoll))
		dolls.add_child(theDoll, true)
		
		if(Network.isServerNotSingleplayer()):
			createDollController_RPC.rpc(theDoll.saveNetworkData())
		
		return theDoll
	return null

func onDollDeleted(doll:DollController):
	if(doll.is_inside_tree()):
		doll.name = "TO_BE_DELETED"
	if(Network.isServerNotSingleplayer()):
		deleteDoll_RPC.rpc(doll.uniqueID)

@rpc("authority", "call_remote", "reliable")
func deleteDoll_RPC(uniqueID:int):
	var theDoll:DollController = findDollWithUniqueID(uniqueID)
	if(!theDoll):
		Log.Printerr("Couldn't find a doll to delete with ID "+str(uniqueID))
		return
	theDoll.queue_free()

@rpc("authority", "call_remote", "reliable")
func createDollController_RPC(dollData:Dictionary):
	Log.Print("createDollController_RPC UID="+str(dollData["UID"]))
	var theDoll:DollController= dollControllerScene.instantiate()
	theDoll.name = str(SAVE.loadVar(dollData, "UID", 0))
	theDoll.tree_exiting.connect(onDollDeleted.bind(theDoll))
	dolls.add_child(theDoll)
	theDoll.loadNetworkData(dollData)

func clearDolls():
	Util.delete_children(dolls)
	
func deleteDoll(theDoll:DollController):
	theDoll.queue_free()

func deleteDollsOfNetworkPlayerID(clientID:int):
	var toRemove:Array = []
	for doll in dolls.get_children():
		if(!(doll is DollController)):
			continue
		if(doll.networkPlayerID == clientID):
			toRemove.append(doll)
	for doll in toRemove:
		doll.queue_free()

func findDollWithUniqueID(theID:int) -> DollController:
	if(dolls.has_node(str(theID))):
		return dolls.get_node(str(theID))
	#
	#for doll in dolls.get_children():
		#if(!(doll is DollController)):
			#continue
		#if(doll.uniqueID == theID):
			#return doll
	return null

func _process(_delta: float) -> void:
	if(curDoll && !is_instance_valid(curDoll)):
		notifyCurrentDollSwitch(null)

func notifyCurrentDollSwitch(_newDoll:DollController):
	if(_newDoll == curDoll):
		return
	var oldDoll:DollController=curDoll
	#if(curDoll && !is_instance_valid(curDoll)):
	#	oldDoll = null
	curDoll = _newDoll
	onCurrentDollSwitch.emit(oldDoll, curDoll)

func saveNetworkData() -> Dictionary:
	var dollData:Array = []
	
	for doll in dolls.get_children():
		if(doll is DollController):
			dollData.append(doll.saveNetworkData())
	
	return {
		dolls = dollData,
	}

func loadNetworkData(_data:Dictionary):
	clearDolls()
	
	var dollData:Array = SAVE.loadVar(_data, "dolls", [])
	for dollEntry in dollData:
		createDollController_RPC(dollEntry)

@rpc("authority", "call_remote", "reliable")
func playGesture_RPC(theDollID:int, _gestureID:String):
	var theDoll:= findDollWithUniqueID(theDollID)
	if(!theDoll):
		return
	
	var shouldFullBody:bool = true
	var shouldPartial:bool = true
	
	var theChar := theDoll.getCharacter()
	if(theChar):
		shouldFullBody = !theChar.isFullbodyGesturesBlocked()
		shouldPartial = !theChar.isPartialGesturesBlocked()
	
	theDoll.getDoll().playGesture(_gestureID, shouldFullBody, shouldPartial)

func playGesture(_doll:DollController, _gestureID:String):
	if(Network.isClient()):
		return
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(playGesture_RPC, [_doll.uniqueID, _gestureID])
	playGesture_RPC(_doll.uniqueID, _gestureID)

@rpc("any_peer", "call_remote", "reliable")
func askPlayGesture_SERVERRPC(theDollID:int, _gestureID:String):
	# Any checks should go here
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(playGesture_RPC, [theDollID, _gestureID])
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
		Network.rpcClients(askLookAtCustom_RPC, [_doll.uniqueID, _pos])
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
		Network.rpcClients(askLookAtClear_RPC, [_doll.uniqueID])
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


func askLookAtDoll(_doll:DollController, _doll2:DollController):
	if(!_doll):
		return
	
	if(!_doll2):
		askLookAt(_doll, null)
	else:
		askLookAt(_doll, _doll2.getDoll().getEyesNode())

func askLookAt(_doll:DollController, _node:Node3D, _howLong:float = 10.0):
	if(!_doll):
		return
	if(Network.isServer()):
		_doll.getDoll().lookAt(_node, _howLong)
	if(Network.isServerNotSingleplayer()):
		var theNode = GameInteractor.getUniqueIDOf(_node)
		Network.rpcClients(askLookAt_RPC, [_doll.uniqueID, theNode, _howLong])
	elif(Network.isClient()):
		var theNode = GameInteractor.getUniqueIDOf(_node)
		askLookAt_ServerRPC.rpc_id(1, _doll.uniqueID, theNode, _howLong)

@rpc("authority", "call_remote", "reliable")
func askLookAt_RPC(dollUniqueID:int, _nodeData, _howLong:float):
	var theDoll := findDollWithUniqueID(dollUniqueID)
	if(!theDoll):
		return
	var theNode = GameInteractor.getNodeByUniqueID(_nodeData)
	if(!theNode):
		return
	theDoll.getDoll().lookAt(theNode, _howLong)

@rpc("any_peer", "call_remote", "reliable")
func askLookAt_ServerRPC(dollUniqueID:int, _nodeData, _howLong:float):
	var theDoll := findDollWithUniqueID(dollUniqueID)
	if(!theDoll):
		return
	var theNode = GameInteractor.getNodeByUniqueID(_nodeData)
	if(!theNode):
		return
	askLookAt(theDoll, theNode, _howLong)
