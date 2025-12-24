extends LeashPoint
class_name DollLeashPoint

var doll:DollController
var pawn:CharacterPawn

#var visualLeashes:Array[LeashVisualInstance] = []
#const LEASH_VISUAL_INSTANCE = preload("res://Game/Systems/LeashSystem/LeashVisualInstance.tscn")

func _ready() -> void:
	super._ready()
	doll = findDollController()
	if(!doll):
		Log.Printerr("SPAWNED A DOLL LEASH POINT THAT ISN'T ATTACHED TO A DOLL CONTROLLER.")
		return
	pawn = doll.getPawn()
	if(!pawn):
		Log.Printerr("DOLL LEASH POINT IS ATTACHED TO A DOLL WITHOUT A PAWN ASSIGNED.")
		return
	pawn.registerLeashPoint(self)
	
func _exit_tree() -> void:
	super._exit_tree()
	if(pawn):
		pawn.unregisterLeashPoint(self)
	
	doll = null
	pawn = null

func findDollController() -> DollController:
	var thePar := get_parent()
	while(thePar):
		if(thePar is DollController):
			return thePar
		thePar = thePar.get_parent()
	return null

#func addConnection(_leashConnection:Array):
#	var thePawn := GM.pawnRegistry.getPawn(_leashConnection[2])
#	var theDoll 
