extends AIComboBase

func _init() -> void:
	id = "ForwardDodgeAttack"
	baseScore = 0.4
	minDistance = 1.0
	maxDistance = 2.5
	#enabled = false
	
func doCombo(_context:AIComboContext):
	_context.pushToQueue(CombatPawnAI.ACTION_MOVE, [Vector2(0.0, RNG.pick([1.0, -1.0])), 0.2])
	_context.pushDelay(0.1)
	_context.pushToQueue(CombatPawnAI.ACTION_DODGE, [Vector2(0.0, 1.0)])
	_context.pushDelay(0.3)
	_context.pushToQueue(CombatPawnAI.ACTION_ATTACK_PICK)
