extends RefCounted
class_name FetishBase

var id:String = ""

func getVisibleName() -> String:
	return "FILL ME"

func getNamePerforming() -> String:
	return "FILL ME"

func getNameReceiving() -> String:
	return "FILL ME"

func generateInitialValuePerforming(_char:BaseCharacter, _gen:CharacterGenerator = null) -> float:
	if(RNG.chance(10.0)):
		return RNG.randfRange(-0.5, -0.2)
	return RNG.randfRange(-0.2, 0.5)

func generateInitialValueReceiving(_char:BaseCharacter, _gen:CharacterGenerator = null) -> float:
	if(RNG.chance(10.0)):
		return RNG.randfRange(-0.5, -0.2)
	return RNG.randfRange(-0.2, 0.5)

# These will still generate but they won't be visible
# All of the fetishes need to be generated in case the character changes in some way and so the fetish would start applying again
func shouldApplyToPerforming(_char:BaseCharacter) -> bool:
	return true

func shouldApplyToReceiving(_char:BaseCharacter) -> bool:
	return true
