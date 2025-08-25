extends BodypartEarBase

var piercings:String = ""
var tassels:bool = false
var piercingsColor:Color = Color.WHITE
var tasselsColor:Color = Color.DIM_GRAY
var pattern:Dictionary = {
	id = "FluffyEar_Default",
	r = Color.LIGHT_CORAL,
	g = Color.GRAY,
	b = Color.DIM_GRAY,
}
var fluffColor:Color = Color.WHITE

func _init():
	super._init()
	id = "FluffyEar"

func getName() -> String:
	return "Fluffy ear"

func getScenePath(_slot:int) -> String:
	if(_slot == BodypartSlot.LeftEar):
		return "res://Mesh/Parts/Ear/FluffyEar/fluffy_ear_l.tscn"
	else:
		return "res://Mesh/Parts/Ear/FluffyEar/fluffy_ear_r.tscn"

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
			editors = [EDITOR_PART],
		}
	theOptions["pattern"] = {
			name = "Pattern",
			type = "pattern",
			texType = TextureVariantType.EarPattern,
			texSubType = "FluffyEar",
			editors = [EDITOR_PART],
		}

	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Ear/FluffyEar/Textures/Patterns/FluffyEarManyPatterns.gd",
	]
