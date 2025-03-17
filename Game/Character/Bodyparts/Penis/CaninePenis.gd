extends BodypartPenisBase

var penisScale:float = 0.8
var penisLenMod:float = 1.0
var penBallsDrop:float = 0.0
var penBallsScale:float = 1.0
var pattern:Dictionary = {
	pattern = "CanineShaft_Default",
	colorR = Color("A3728A"),
	colorG = Color("954555"),
	colorB = Color("490979"),
}
var shaftColor:Color = Color("954555")
var furTuft:bool = true
var furTuftColor:Color = Color.GRAY

func _init():
	id = "CaninePenis"

func getName() -> String:
	return "Canine penis"

func getScenePath(_slot:String) -> String:
	return "res://Mesh/Parts/Penis/CaninePenis/canine_penis.tscn"

func getSupportedSkinTypes() -> Dictionary:
	return {
		SkinType.Fur: true,
	}

func getOptions() -> Dictionary:
	var theOptions:Dictionary = super.getOptions()
	theOptions["shaftColor"] = {
			name = "Shaft color",
			type = "color",
			editors = ["skin"],
		}
	theOptions["pattern"] = {
			name = "Pattern",
			type = "pattern",
			texType = TextureVariantType.PenisPattern,
			texSubType = "CanineShaft",
			editors = ["skin"],
		}
	theOptions["penisScale"] = {
			name = "Size",
			type = "slider",
			min = 0.5,
			max = 1.5,
			editors = ["part"],
		}
	theOptions["penisLenMod"] = {
			name = "Length",
			type = "slider",
			min = 0.2,
			max = 2.0,
			editors = ["part"],
		}
	theOptions["penBallsDrop"] = {
			name = "Balls position",
			type = "slider",
			min = -0.02,
			max = 0.02,
			editors = ["part"],
		}
	theOptions["penBallsScale"] = {
			name = "Balls scale",
			type = "slider",
			min = 0.0,
			max = 2.0,
			editors = ["part"],
		}
	theOptions["furTuft"] = {
			name = "Fur tufts",
			type = "bool",
			editors = ["part"],
		}
	theOptions["furTuftColor"] = {
			name = "Fur tufts color",
			type = "color",
			editors = ["part"],
		}
		
	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Penis/CaninePenis/Textures/ShaftPatterns/CaninePenisShaftTexVariantsMany.gd",
	]
