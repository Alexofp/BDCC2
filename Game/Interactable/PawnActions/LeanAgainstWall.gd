extends PawnActionBase

func _init() -> void:
	id = "LeanAgainstWall"
	alwaysCheckBitfield = CHECK_SELF

func getVisibleName(_context:PawnActionContext) -> String:
	return "Lean against wall"

func canDoAction(_context:PawnActionContext) -> bool:
	if(!GM.main.checkCanLean(_context.pawn.global_position, _context.pawn.global_rotation)):
		return false
	if(GM.sitManager.isSitting(_context.pawn)):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	if(!GM.main.checkCanLean(_context.pawn.global_position, _context.pawn.global_rotation)):
		return false
	var theTransform := GM.main.wall_checker.getLeanTransform()
	
	var theHandler:PackedScene = load("res://AnimScenes/Scenes/SoloSex/AgainstWallAnimHandler.tscn")
	if(!theHandler):
		return false
	var newWallHandler:Node3D = theHandler.instantiate()
	GM.netNodes.add_child(newWallHandler, true)
	newWallHandler.global_transform = theTransform
	GM.netNodes.notifySpawned(newWallHandler)
	
	newWallHandler.setSitter("dom", _context.pawn)
	
	#GM.sexManager.askStartMasturbation(_context.pawn.getCharID())
	#startDelayedAction(_context, 2.0)
	return true

#func doDelayedAction(_context:PawnActionContext) -> bool:
	#GM.sexManager.askStartMasturbation(_context.pawn.getCharID())
	#return true
