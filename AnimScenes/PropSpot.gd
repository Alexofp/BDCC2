extends Marker3D
class_name PropSpot

#var sitter:WeakRef
#var doll:DollController

var prop:Node3D
#var propNodePath:NodePath

#signal onPawnSwitch(newPawn)
signal onPropSwitch(newProp:Node3D, oldProp:Node3D)
#@onready var sitter_node: SyncNode = %SitterNode

var propAnimKey:String = ""

#func checkSitter():
	#if(hasSitter()):
		#var theSitter = getSitter()
		#if(!theSitter):
			#unSit()
			#return
		#if(theSitter is DollController):
			#if(theSitter.getPoseSpot() != self):
				#unSit()

func hasProp() -> bool:
	return !!getProp()
	
func getProp() -> Node3D:
	return prop
#
#func dollUpdate():
	#var oldDoll := doll
	#var newDoll := getSitterDoll()
	#
	#if(oldDoll == newDoll):
		#return
	#doll = newDoll
	#
	#onDollSwitch.emit(doll, oldDoll)

func setProp(_newProp:Node3D):
	#setPawn(theSitter)
	var oldProp := prop
	prop = _newProp
	
	onPropSwitch.emit(prop, oldProp)

func unSit():
	if(!prop):
		return
	var theProp := prop
	prop = null
	
	onPropSwitch.emit(prop, theProp)
#
#func _exit_tree() -> void:
	##if(hasSitterPawn()):
	##	unSit()
	#if(GM.sitManager):
		#GM.sitManager.handleDeletionOfSeat(self)

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

#func _process(_delta: float) -> void:
	#dollUpdate()
	#if(!hasSitterPawn() && sitter):
	#	setPawn(null)

#func onPawnChange(_newPawn:CharacterPawn):
	##Log.Print("NEW POSE SEAT PAWN "+str(_newPawn))
	#
	#onPawnSwitch.emit(_newPawn)
	#dollUpdate()
