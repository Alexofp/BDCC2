extends Node3D
class_name CharacterPawn


@export var id:String = ""
var doll:DollController
#var poseSpot:PoseSpot

@onready var doll_node: SyncNode = %DollNode
#@onready var sit_node: SyncNode = %SitNode

signal dollSpawned(doll)
signal dollDespawned(doll)
signal dollSwitched(newdoll, olddoll)

func getCharacter() -> BaseCharacter:
	if(GM.characterRegistry):
		return GM.characterRegistry.getCharacter(id)
	return null

func getCharID() -> String:
	return id

func getDoll() -> DollController:
	return doll

func shouldDollBeSpawned() -> bool:
	for playerID in Network.players:
		var info:NetworkPlayerInfo = Network.players[playerID]
		if(info.charID == id):
			return true
	if(GM.pawnRegistry.shouldPawnDollBeSpawned(self)):
		return true
	return false

func _process(_delta: float) -> void:
	#if(is_queued_for_deletion()): #HACK fixes a crash when hosting with NORAY, dunno
	#	return
	if(Network.isServer()):
		var shouldBeSpawned:bool = shouldDollBeSpawned()
		
		if(isDollSpawned()):
			position = doll.position
			
			if(!shouldBeSpawned): # || RNG.chance(1)
				despawnDoll()
		else:
			if(shouldBeSpawned): # && RNG.chance(1)
				spawnDoll()
	
	
func isDollSpawned() -> bool:
	return !!doll

func spawnDoll():
	if(!Network.isServer()):
		return
	if(doll):
		assert(false, "Doll already spawned")
		return
	var newDoll: = GM.dollHolder.createDollControllerForPawn(self)
	newDoll.tree_exiting.connect(dollOnDelete)
	doll_node.setNode(newDoll)

func despawnDoll():
	if(!doll):
		assert(false, "Doll doesn't exist")
		return
	GM.dollHolder.deleteDoll(doll)
	doll_node.setNode(null)

func dollOnDelete():
	doll_node.setNode(null)

func isControlledByUs() -> bool:
	var myInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
	if(!myInfo):
		return false
	return myInfo.charID == id

func saveNetworkData() -> Dictionary:
	return {
		pos = position,
	}

func loadNetworkData(_data:Dictionary):
	position = SAVE.loadVar(_data, "pos", position)

func _on_doll_node_on_node_changed(newNode: Variant) -> void:
	var tempDoll = doll
	doll = newNode
	
	if(doll):
		Log.Print("DOLL GOT SPAWNED")
		doll.updatePoseSpot()
		dollSpawned.emit(doll)
	elif(tempDoll && !doll):
		Log.Print("DOLL GOT DESPAWNED")
		dollDespawned.emit(tempDoll)
	if(doll != tempDoll):
		dollSwitched.emit(doll, tempDoll)

#func _on_sit_node_on_node_changed(newNode: Variant) -> void:
	#poseSpot = newNode
	# # Notify doll
	#var theDoll:=getDoll()
	#if(theDoll):
		#theDoll.updatePoseSpot()
#
#func setPoseSpot(newPoseSpot:PoseSpot):
	#if(Network.isClient()):
		#assert(false, "Client trying to set pose spot. Only server should do it")
		#return
	#sit_node.setNode(newPoseSpot)

func getPoseSpot() -> PoseSpot:
	return GM.sitManager.getSeatOfPawn(self)

func _exit_tree() -> void:
	GM.sitManager.handleDeletionOfPawn(self)
	if(Network.isServer()):
		if(doll):
			despawnDoll()

func canSit() -> bool:
	return !GM.sitManager.isSitting(self)

## Called by sit manager
func onSeatChange(_newSpot:PoseSpot):
	var theDoll := getDoll()
	if(theDoll):
		theDoll.onSeatChange(_newSpot)
