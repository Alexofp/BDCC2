extends BodypartEarBase

var piercings:String = ""
var tassels:bool = false
var piercingsColor:Color = Color.WHITE
var tasselsColor:Color = Color.DIM_GRAY
var pattern:Dictionary = {
	pattern = "FelineEar_Default",
	colorR = Color.LIGHT_CORAL,
	colorG = Color.GRAY,
	colorB = Color.DIM_GRAY,
}
var fluffColor:Color = Color.WHITE

func _init():
	id = "FelineEar"

func getName() -> String:
	return "Feline ear"

func getScenePath(_slot:int) -> String:
	if(_slot == BodypartSlot.LeftEar):
		return "res://Mesh/Parts/Ear/FelineEar/feline_ear_l.tscn"
	else:
		return "res://Mesh/Parts/Ear/FelineEar/feline_ear_r.tscn"

func getSupportedSkinTypes() -> Dictionary:
	return {
		SkinType.Fur: true,
	}

func getOptions() -> Dictionary:
	var theOptions:Dictionary = super.getOptions()
	theOptions["piercings"] = {
			name = "Piercings",
			type = "selector",
			values = [
				["", "No piercings"],
				["TwoRings", "Two rings"],
			],
			editors = [EDITOR_PART],
		}
	theOptions["piercingsColor"] = {
			name = "Piercings color",
			type = "color",
			editors = [EDITOR_PART],
		}
	theOptions["tassels"] = {
			name = "Tassels",
			type = "bool",
			editors = [EDITOR_PART],
		}
	theOptions["tasselsColor"] = {
			name = "Tassels color",
			type = "color",
			editors = [EDITOR_PART],
		}
	theOptions["fluffColor"] = {
			name = "Fluff color",
			type = "color",
			alpha = true,
			editors = [EDITOR_SKIN],
		}
	theOptions["pattern"] = {
			name = "Pattern",
			type = "pattern",
			texType = TextureVariantType.EarPattern,
			texSubType = "FelineEar",
			editors = [EDITOR_SKIN],
		}

	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Ear/FelineEar/Textures/Patterns/FelineEarManyPatterns.gd",
	]
