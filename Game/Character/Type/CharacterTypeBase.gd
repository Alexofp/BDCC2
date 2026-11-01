extends RefCounted
class_name CharacterTypeBase

var id:int = CharacterType.Generic
var inmate:bool = false
var staff:bool = false
var colorMain:Color = Color.WHITE
var allowPickAsPlayer:bool = false
var allowPick:bool = true
var scoreBase:float = 1.0

func getName() -> String:
	return "Error:"+str(id)

func isInmate() -> bool:
	return inmate

func isStaff() -> bool:
	return staff

func getMainColor() -> Color:
	return colorMain

func giveDefaultClothes(_char:BaseCharacter):
	pass

func canBePickedAsPlayer() -> bool:
	return allowPickAsPlayer

func canBePicked() -> bool:
	return allowPick

# Not used
func calcScore(_char:BaseCharacter) -> float:
	return scoreBase
