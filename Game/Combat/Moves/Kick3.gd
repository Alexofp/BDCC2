extends CombatMoveBase

func _init() -> void:
	id = "Kick3"
	animation = "Kick3"
	moveLen = 0.0
	noMoveLen = 1.0
	
	activateType = ACTIVATE_SPACE
	
	priority = 10
	conditions = [
		[COND_TAG_ANY, ["ak2", "ap3"]],
	]
	initialEffects = [
		[EFFECT_DELAY, 0.15],
		[EFFECT_MOVE, Vector3(0.0, 0.0, 1.0), 0.6],
		[EFFECT_DELAY, 0.2],
		[EFFECT_TAG, TAG_BLOCK_DODGE, 0.45],
		[EFFECT_HIT, AttackInfo.create(2.0, 2.2, 20.0).setKnock(1.0, 3.0).setExhaust(0.1).setCollapses(10.0, 5.0), EFFECTS_KICK_RIGHT, INTENSITY_STRONG],
		[EFFECT_DELAY, 0.8],
		#[EFFECT_MOVE, Vector3(0.0, 0.0, -3.0), 0.4],
		[EFFECT_TAG, "ak3", 0.5], # ak1 = after kick 1
	]
	cancelEffects = [
		[EFFECT_TAG, "ak3", 1.0],
	]
