extends CombatMoveBase

func _init() -> void:
	id = "LegSweep"
	animation = "LegSweep"
	moveLen = 0.0
	noMoveLen = 1.0
	
	activateType = ACTIVATE_SPACE
	
	priority = 50
	conditions = []
	initialEffects = [
		[EFFECT_DELAY, 0.15],
		[EFFECT_MOVE, Vector3(0.0, 0.0, -1.0), 0.7],
		[EFFECT_TAG, TAG_BLOCK_DODGE, 0.65],
		[EFFECT_DELAY, 0.2],
		[EFFECT_HIT, AttackInfo.create(1.0, 2.2, 70.0).setExhaust(0.2).setHitAll(true), EFFECTS_KICK_RIGHT],
		[EFFECT_DELAY, 0.4],
		#[EFFECT_MOVE, Vector3(0.0, 0.0, -3.0), 0.4],
		[EFFECT_TAG, "als", 0.5], # after leg sweep
	]

func canUse(_player:CombatMovePlayer) -> bool:
	var theVel := _player.getCurrentControlsDir()
	if(theVel.length_squared() < 0.3):
		return false
	if(abs(theVel.x) < 0.2 && theVel.z < -0.5):
		return true
	#theVel = theVel.normalized()
	
	return false
