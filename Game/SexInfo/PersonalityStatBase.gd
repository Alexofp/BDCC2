extends RefCounted
class_name PersonalityStatBase

var id:String = ""
var priority:float = 0.0

func getVisibleName() -> String:
	return "FILL ME"

func getNamePositive() -> String:
	return "FILL ME"

func getNameNegative() -> String:
	return "FILL ME"

func generateInitialValue(_char:BaseCharacter, _gen:CharacterGenerator = null) -> float:
	if(RNG.chance(10.0)):
		return RNG.randfRange(-1.0, 1.0)
	return RNG.randfRange(-0.6, 0.6)
