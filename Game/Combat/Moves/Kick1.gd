extends CombatMoveBase

func _init() -> void:
	id = "Kick1"
	animation = "Kick"
	moveLen = 0.0
	noMoveLen = 0.7
	
	activateType = ACTIVATE_SPACE
	
	priority = 0
	conditions = []
	initialEffects = [
		[EFFECT_DELAY, 0.15],
		[EFFECT_MOVE, Vector3(0.0, 0.0, 3.0), 0.4],
		[EFFECT_DELAY, 0.15],
		[EFFECT_HIT, AttackInfo.create(2.0, 2.2, 20.0).setKnock(1.0, 3.0).setExhaust(0.1), EFFECTS_KICK_RIGHT, INTENSITY_STRONG],
		[EFFECT_DELAY, 0.45],
		#[EFFECT_MOVE, Vector3(0.0, 0.0, -3.0), 0.4],
		[EFFECT_TAG, "ak1", 0.5], # ak1 = after kick 1
	]
	cancelEffects = [
		[EFFECT_TAG, "ak1", 1.0],
	]
