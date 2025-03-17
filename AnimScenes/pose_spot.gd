extends Marker3D
class_name PoseSpot

#var sitter:WeakRef
var doll:DollController

signal onPawnSwitch(newPawn)
signal onDollSwitch(newDoll)
#@onready var sitter_node: SyncNode = %SitterNode

#func checkSitter():
	#if(hasSitter()):
		#var theSitter = getSitter()
		#if(!theSitter):
			#unSit()
			#return
		#if(theSitter is DollController):
			#if(theSitter.getPoseSpot() != self):
				#unSit()

func hasSitterPawn() -> bool:
	return !!getSitterPawn()

func hasSitter() -> bool:
	return !!getSitterPawn()
	
func getSitterPawn() -> CharacterPawn:
	#if(sitter == null):
		#return null
	#return sitter.get_ref()
	if(!GM.sitManager):
		return null
	return GM.sitManager.getPawnSittingOn(self)

func hasSitterDoll() -> bool:
	var thePawn:CharacterPawn = getSitterPawn()
	if(!thePawn):
		return false
	var theDoll:DollController = thePawn.getDoll()
	if(!theDoll):
		return false
	return true

func getSitterDoll() -> DollController:
	var thePawn:CharacterPawn = getSitterPawn()
	if(!thePawn):
		return null
	var theDoll:DollController = thePawn.getDoll()
	return theDoll

#func setPawn(newPawn:CharacterPawn):
	#if(Network.isServer()):
		#sitter_node.setNode(newPawn)

func dollUpdate():
	var oldDoll := doll
	var newDoll := getSitterDoll()
	
	if(oldDoll == newDoll):
		return
	doll = newDoll
	
	onDollSwitch.emit(doll)

func doSit(theSitter:CharacterPawn):
	#setPawn(theSitter)
	GM.sitManager.doSit(theSitter, self)

func unSit():
	#setPawn(null)
	GM.sitManager.freeSeat(self)

func doSitDoll(theDoll:DollController):
	if(theDoll):
		doSit(theDoll.getPawn())
	else:
		doSit(null)

func _exit_tree() -> void:
	#if(hasSitterPawn()):
	#	unSit()
	if(GM.sitManager):
		GM.sitManager.handleDeletionOfSeat(self)

#func _on_sitter_node_on_node_changed(newPawn: Variant) -> void:
	#Log.Print("NEW POSE SEAT PAWN "+str(newPawn))
	#var oldPawn := getSitterPawn()
	#var gotNulled:bool = (!oldPawn && !newPawn && sitter)
	#
	#if(newPawn == oldPawn && !gotNulled):
		#return
	#if(oldPawn && Network.isServer()):
		#oldPawn.setPoseSpot(null)
	#
	#sitter = weakref(newPawn) if newPawn else null
	#
	#if(newPawn && Network.isServer()):
		#newPawn.setPoseSpot(self)
		#
	#onPawnSwitch.emit(newPawn)
	#dollUpdate()

func _process(_delta: float) -> void:
	dollUpdate()
	#if(!hasSitterPawn() && sitter):
	#	setPawn(null)

func onPawnChange(_newPawn:CharacterPawn):
	Log.Print("NEW POSE SEAT PAWN "+str(_newPawn))
	
	onPawnSwitch.emit(_newPawn)
	dollUpdate()
