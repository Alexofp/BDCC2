
extends CombatMoveBase

func _init() -> void:
	id = "Punch3"
	animation = "Punch3"
	moveLen = 0.0
	noMoveLen = 0.4
	
	activateType = ACTIVATE_ATTACK1
	
	priority = 8
	conditions = [
		[COND_TAG, "ap2"],
	]
	initialEffects = [
		[EFFECT_DELAY, 0.15],
		[EFFECT_MOVE, Vector3(0.0, 0.0, 3.0), 0.4],
		[EFFECT_DELAY, 0.1],
		[EFFECT_HIT, AttackInfo.create(1.0, 1.8, 30.0), EFFECTS_PUNCH_LEFT, INTENSITY_STRONG],
		[EFFECT_DELAY, 0.3],
		#[EFFECT_EVENT, "test"],
		#[EFFECT_HIT, "hit"],
		[EFFECT_TAG, "ap3", 0.5],
	]
