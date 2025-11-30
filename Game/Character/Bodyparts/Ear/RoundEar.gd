extends BodypartEarBase

#var tassels:bool = false
#var tasselsColor:Color = Color.DIM_GRAY
var pattern:Dictionary = {
	id = "RoundEar_Default",
	r = Color.LIGHT_CORAL,
	g = Color.GRAY,
	b = Color.DIM_GRAY,
}
var fluffColor:Color = Color.WHITE

func _init():
	super._init()
	id = "RoundEar"

func getName() -> String:
	return "Round ear"

func getScenePath(_slot:int) -> String:
	if(_slot == BodypartSlot.LeftEar):
		return "res://Mesh/Parts/Ear/RoundEar/round_ear_l.tscn"
	else:
		return "res://Mesh/Parts/Ear/RoundEar/round_ear_r.tscn"

func getSupportedSkinTypes() -> Dictionary:
	return {
		SkinType.Fur: true,
	}

func getOptions() -> Dictionary:
	var theOptions:Dictionary = super.getOptions()
	theOptions["fluffColor"] = {
			name = "Fluff color",
			type = "color",
			editors = [EDITOR_PART],
		}
	theOptions["pattern"] = {
			name = "Pattern",
			type = "pattern",
			texType = TextureVariantType.EarPattern,
			texSubType = "RoundEar",
			editors = [EDITOR_PART],
		}

	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Ear/RoundEar/Patterns/RoundManyPatterns.gd",
	]
