extends AIComboBase

func _init() -> void:
	id = "LegSweep"
	baseScore = 0.3
	#recoveryTimeMin = 0.5
	#recoveryTimeMax = 0.4
	#enabled = false
	
func doCombo(_context:AIComboContext):
	_context.pushToQueue(CombatPawnAI.ACTION_MOVE, [Vector2(0.0, -1.0), 0.3])
	_context.pushDelay(0.1)
	_context.pushToQueue(CombatPawnAI.ACTION_ATTACK_HEAVY)
