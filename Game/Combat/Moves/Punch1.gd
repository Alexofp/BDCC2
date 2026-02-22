extends CombatMoveBase

func _init() -> void:
	id = "Punch1"
	animation = "Punch"
	moveLen = 0.0
	noMoveLen = 0.4
	
	activateType = ACTIVATE_ATTACK1
	
	priority = 0
	conditions = []
	initialEffects = [
		[EFFECT_DELAY, 0.15],
		[EFFECT_MOVE, Vector3(0.0, 0.0, 3.0), 0.4],
		[EFFECT_DELAY, 0.15],
		#[EFFECT_EVENT, "test"],
		[EFFECT_HIT, AttackInfo.create(1.0, 1.8, 30.0)],
		[EFFECT_DELAY, 0.15],
		#[EFFECT_HIT, "punch1", 1.8, 30.0],
		[EFFECT_TAG, "ap1", 0.5], # ap1 = after punch 1
	]
	cancelEffects = [
		[EFFECT_TAG, "ap1", 1.0],
	]

func onEvent(_player:CombatMovePlayer, _eventID:String, _args:Array):
	Log.Print("COMBAT MOVE EVENT! move="+id+" EVENT ID="+_eventID)
	#Log.Print(str(_player.getTargets(1.5, 45.0)))
	_player.doStrike(AttackInfo.create(1.0, 1.8, 30.0))
	pass
