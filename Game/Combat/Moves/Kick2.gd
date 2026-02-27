extends CombatMoveBase

func _init() -> void:
	id = "Kick2"
	animation = "Kick2"
	moveLen = 0.0
	noMoveLen = 0.7
	
	activateType = ACTIVATE_SPACE
	
	priority = 5
	conditions = [
		[COND_TAG_ANY, ["ak1", "als"]],
	]
	initialEffects = [
		[EFFECT_DELAY, 0.15],
		[EFFECT_MOVE, Vector3(0.0, 0.0, 1.0), 0.6],
		[EFFECT_DELAY, 0.2],
		[EFFECT_HIT, AttackInfo.create(2.0, 2.2, 20.0).setKnock(1.0, 3.0).setExhaust(0.1), EFFECTS_KICK_LEFT],
		[EFFECT_DELAY, 0.4],
		#[EFFECT_MOVE, Vector3(0.0, 0.0, -3.0), 0.4],
		[EFFECT_TAG, "ak2", 0.5],
	]
	cancelEffects = [
		[EFFECT_TAG, "ak2", 1.0],
	]
