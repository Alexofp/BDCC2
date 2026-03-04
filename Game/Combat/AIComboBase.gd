extends RefCounted
class_name AIComboBase

var id:String = "error"

var enabled:bool = true

# Distance helper guide
# 0.6 = pressed tightly against the target
# 1.2 = usual distance between target and attacker, comfortable for any attack
# 2.3 = about as far as you can get with a superman punch

var minDistance:float = 0.0
var maxDistance:float = 2.0

var minExhaustion:float = 0.0
var maxExhaustion:float = 0.5

var recoveryTimeMin:float = 0.2
var recoveryTimeMax:float = 1.0

var baseScore:float = 1.0
#var finalScoreMult:float = 1.0

var combo:Array[Array] = [
	#[CombatPawnAI.ACTION_DODGE, [Vector2(1.0, 0.0)]],
	#[CombatPawnAI.ACTION_WAIT_NO_MOVE],
	#[CombatPawnAI.ACTION_MOVE, [Vector2(1.0, 0.0), 0.5]],
	#[CombatPawnAI.ACTION_ATTACK_HEAVY],
	#[CombatPawnAI.ACTION_ATTACK],
	#[CombatPawnAI.ACTION_BLOCK, [2.0]],
]

func canDoCombo(_context:AIComboContext) -> bool:
	if(_context.distance < minDistance || _context.distance > maxDistance):
		return false
	var theExhaustion:float = _context.pawn.combatMovePlayer.getExhaustionLevel()
	if(theExhaustion < minExhaustion || theExhaustion > maxExhaustion):
		return false
	return true

func getComboScore(_context:AIComboContext) -> float:
	return baseScore

func doCombo(_context:AIComboContext):
	for comboEntry in combo:
		if(comboEntry.size() > 2 && !RNG.chance(comboEntry[2])):
			continue
		_context.pawn.combatAI.pushToQueue(comboEntry[0], comboEntry[1] if comboEntry.size() > 1 else [])

func doComboEffects(_context:AIComboContext):
	_context.pawn.combatAI.timeUntilNextMove = RNG.randfRange(recoveryTimeMin, recoveryTimeMax)
