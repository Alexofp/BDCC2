extends Object
class_name SkinType

enum {
	None,
	Auto,
	HumanSkin,
	Fur,
	Scales,
	Latex,
	Android,
	Feathers,
}

const NAMES = [
	"None", "Auto", "Skin", "Fur", "Scales", "Latex", "Android", "Feathers",
]
const NAMES_RAW = [
	"None",
	"Auto",
	"HumanSkin",
	"Fur",
	"Scales",
	"Latex",
	"Android",
	"Feathers",
]

static func getName(skinType:int) -> String:
	if(skinType < 0 || skinType >= NAMES.size()):
		return "Unknown"
	return NAMES[skinType]

static func stringToType(_skinTypeStr:String) -> int:
	for _i in range(NAMES_RAW.size()):
		if(NAMES_RAW[_i] == _skinTypeStr):
			return _i
	
	return None

static func isActualSkinType(_skinType:int) -> bool:
	if(_skinType in [None, Auto]):
		return false
	return true
