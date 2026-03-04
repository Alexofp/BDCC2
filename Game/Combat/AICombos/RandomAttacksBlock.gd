extends AIComboBase

func _init() -> void:
	id = "RandomAttacksBlock"
	
	baseScore = 1.0
	#enabled = false

func doCombo(_context:AIComboContext):
	_context.pushToQueue(CombatPawnAI.ACTION_ATTACK_PICK)
	_context.pushToQueue(CombatPawnAI.ACTION_WAIT_NO_MOVE)
	_context.pushToQueue(CombatPawnAI.ACTION_ATTACK_PICK)
	_context.pushToQueue(CombatPawnAI.ACTION_WAIT_NO_MOVE)
	_context.pushToQueue(CombatPawnAI.ACTION_ATTACK_PICK)
	if(RNG.chance(60)):
		_context.pushToQueue(CombatPawnAI.ACTION_WAIT_NO_MOVE)
		_context.pushToQueue(CombatPawnAI.ACTION_BLOCK, [RNG.randfRange(1.0, 2.0)])
