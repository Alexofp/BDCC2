extends CombatMoveBase

func _init() -> void:
	id = "Dodge"
	animation = ""
	moveLen = 0.0
	noMoveLen = 0.4
	canCancelExistingMove = true
	
	activateType = ACTIVATE_SHIFT
	
	priority = 0
	conditions = [
		[COND_NO_TAG, TAG_DODGING],
	]
	initialEffects = [
		[EFFECT_TAG, TAG_DODGING, 0.4],
		[EFFECT_MOVE, Vector3(0.0, 0.0, -5.0), 0.4],
		[EFFECT_DELAY, 0.1],
		[EFFECT_TAG, TAG_AFTER_DODGE, 0.5],
	]

func startMove(_player:CombatMovePlayer):
	var theVel := _player.getCurrentControlsDir()
	if(theVel.length_squared() < 0.3):
		theVel = Vector3(0.0, 0.0, -1.0)
	theVel = theVel.normalized()
	
	initialEffects[1][1] = theVel * 5.0
	
	super.startMove(_player)
