extends AIComboBase

func _init() -> void:
	id = "RandomShuffle"
	baseScore = 0.3
	maxExhaustion = 1.0
	recoveryTimeMin = 0.2
	recoveryTimeMax = 0.4
	#enabled = false
	
func doCombo(_context:AIComboContext):
	var theDir:Vector2 = RNG.pick([Vector2(1.0, 0.0), Vector2(-1.0, 0.0), Vector2(0.0, -1.0)])
	_context.pushToQueue(CombatPawnAI.ACTION_MOVE, [theDir, RNG.randfRange(0.2, 0.4)])
	
