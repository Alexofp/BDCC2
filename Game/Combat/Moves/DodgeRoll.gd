extends CombatMoveBase

func _init() -> void:
	id = "DodgeRoll"
	animation = "DodgeRoll"
	moveLen = 0.0
	noMoveLen = 1.0
	canCancelExistingMove = true
	followVelocityDir = true
	
	activateType = ACTIVATE_SHIFT
	
	priority = 1
	conditions = [
		[COND_TAG, TAG_CAN_ROLL],
		[COND_NO_TAG, TAG_ROLLING],
	]
	initialEffects = [
		[EFFECT_TAG, TAG_ROLLING, 1.5],
		[EFFECT_MOVE, Vector3(0.0, 0.0, 10.0), 1.0],
		[EFFECT_DELAY, 1.0],
		#[EFFECT_TAG, TAG_AFTER_DODGE, 0.5],
	]

#func startMove(_player:CombatMovePlayer):
	#var theVel := _player.getCurrentControlsDir()
	#if(theVel.length_squared() < 0.3):
		#theVel = Vector3(0.0, 0.0, 1.0)
	#theVel = theVel.normalized()
	#
	#initialEffects[1][1] = theVel * 10.0
	#
	##_player.pawn.doDodgeAnim(Vector2(theVel.x, theVel.z))
	#
	#super.startMove(_player)
