extends CombatMoveBase

func _init() -> void:
	id = "Dodge"
	animation = ""
	moveLen = 0.0
	noMoveLen = 0.4
	canCancelExistingMove = true
	ignoresNoAttackTimer = true
	exhaustionOnStart = 0.2
	
	activateType = ACTIVATE_SHIFT
	
	priority = 0
	conditions = [
		[COND_NO_TAG, TAG_DODGING],
		[COND_NO_TAG, TAG_ROLLING],
		[COND_NO_TAG, TAG_BLOCK_DODGE],
	]
	initialEffects = [
		[EFFECT_DODGE_ALL_ATTACKS, 0.6],
		[EFFECT_TAG, TAG_CAN_ROLL, 0.3],
		[EFFECT_TAG, TAG_DODGING, 0.5],
		[EFFECT_TAG, TAG_DODGING_FORWARD, 0.5],
		[EFFECT_MOVE, Vector3(0.0, 0.0, -5.0), 0.6],
		[EFFECT_DELAY, 0.1],
		[EFFECT_SOUND, SOUND_DODGE],
		[EFFECT_DELAY, 0.2],
		[EFFECT_TAG, TAG_AFTER_DODGE, 0.5],
	]

func startMove(_player:CombatMovePlayer):
	var theVel := _player.getCurrentControlsDir()
	if(theVel.length_squared() < 0.3):
		theVel = Vector3(0.0, 0.0, -1.0)
	theVel = theVel.normalized()
	
	initialEffects[4][1] = theVel * 5.0
	if(theVel.z > 0.5 && abs(theVel.x) <= 0.1):
		initialEffects[3][2] = 0.5
		initialEffects[0][1] = 0.2 # Dodging forward gives less i-frames
	else:
		initialEffects[3][2] = 0.0
	
	_player.pawn.doDodgeAnim(Vector2(theVel.x, theVel.z))
	
	super.startMove(_player)
