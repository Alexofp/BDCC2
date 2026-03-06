
extends CombatMoveBase

func _init() -> void:
	id = "Punch2"
	animation = "Punch2"
	moveLen = 0.0
	noMoveLen = 0.4
	
	activateType = ACTIVATE_ATTACK1
	
	priority = 5
	conditions = [
		[COND_TAG, "ap1"],
	]
	initialEffects = [
		[EFFECT_DELAY, 0.15],
		[EFFECT_MOVE, Vector3(0.0, 0.0, 3.0), 0.4],
		[EFFECT_DELAY, 0.15],
		[EFFECT_HIT, AttackInfo.create(0.75, 1.8, 30.0), EFFECTS_PUNCH_RIGHT],
		[EFFECT_DELAY, 0.15],
		#[EFFECT_EVENT, "test"],
		#[EFFECT_HIT, "hit"],
		[EFFECT_TAG, "ap2", 0.5],
	]
