extends AIComboBase

func _init() -> void:
	id = "DodgeAttackDodge"
	baseScore = 0.2
	#enabled = false
	
func doCombo(_context:AIComboContext):
	_context.pushToQueue(CombatPawnAI.ACTION_DODGE, [Vector2(RNG.pick([1.0, -1.0]), 0.0)])
	_context.pushToQueue(CombatPawnAI.ACTION_WAIT_NO_MOVE)
	_context.pushToQueue(CombatPawnAI.ACTION_ATTACK_PICK)
	if(RNG.chance(70)):
		_context.pushToQueue(CombatPawnAI.ACTION_WAIT_NO_MOVE)
		_context.pushToQueue(CombatPawnAI.ACTION_DODGE, [Vector2(RNG.pick([1.0, -1.0]), 0.0)])
	elif(RNG.chance(20)):
		_context.pushToQueue(CombatPawnAI.ACTION_WAIT_NO_MOVE)
		_context.pushToQueue(CombatPawnAI.ACTION_DODGE, [Vector2(0.0, -1.0)])
