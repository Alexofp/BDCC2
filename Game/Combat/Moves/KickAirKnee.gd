extends CombatMoveBase

func _init() -> void:
	id = "KickAirKnee"
	animation = "KickAirKnee"
	moveLen = 0.0
	noMoveLen = 0.7
	canCancelExistingMove = true
	
	activateType = ACTIVATE_SPACE
	
	priority = 10
	conditions = [
		[COND_TAG, TAG_DODGING_FORWARD],
		[COND_JUST_CONSUME, TAG_DODGING],
		[COND_NO_TAG, "nosp"],
	]
	initialEffects = [
		[EFFECT_TAG, "nosp", 0.8],
		[EFFECT_MOVE, Vector3(0.0, 0.0, 3.0), 0.4],
		#[EFFECT_DELAY, 0.15],
		[EFFECT_DELAY, 0.2],
		[EFFECT_HIT, AttackInfo.create(1.0, 1.8, 30.0).setKnock(2.0, 5.0), EFFECTS_KICK_RIGHT],
		[EFFECT_DELAY, 0.2],
		[EFFECT_TAG, "ak2", 0.5],
		#[EFFECT_EVENT, "test"],
		#[EFFECT_HIT, "hit"],
		#[EFFECT_TAG, "ap1", 0.5], # ap1 = after punch 1
	]
