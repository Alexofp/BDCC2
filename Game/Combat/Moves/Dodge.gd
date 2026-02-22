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
		[COND_NO_TAG, TAG_ROLLING],
	]
	initialEffects = [
		[EFFECT_TAG, TAG_CAN_ROLL, 0.3],
		[EFFECT_TAG, TAG_DODGING, 0.5],
		[EFFECT_TAG, TAG_DODGING_FORWARD, 0.5],
		[EFFECT_MOVE, Vector3(0.0, 0.0, -5.0), 0.6],
		[EFFECT_DELAY, 0.3],
		[EFFECT_TAG, TAG_AFTER_DODGE, 0.5],
	]

func startMove(_player:CombatMovePlayer):
	var theVel := _player.getCurrentControlsDir()
	if(theVel.length_squared() < 0.3):
		theVel = Vector3(0.0, 0.0, -1.0)
	theVel = theVel.normalized()
	
	initialEffects[3][1] = theVel * 5.0
	if(theVel.z > 0.5 && abs(theVel.x) <= 0.1):
		initialEffects[2][2] = 0.5
	else:
		initialEffects[2][2] = 0.0
	
	_player.pawn.doDodgeAnim(Vector2(theVel.x, theVel.z))
	
	super.startMove(_player)
