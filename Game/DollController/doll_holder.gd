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
