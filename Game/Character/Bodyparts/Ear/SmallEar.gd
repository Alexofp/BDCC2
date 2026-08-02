extends BodypartEarBase

var tassels:bool = false
var tasselsColor:Color = Color.DIM_GRAY
var pattern:Dictionary = {
	id = "SmallEar_Default",
	r = Color.LIGHT_CORAL,
	g = Color.GRAY,
	b = Color.DIM_GRAY,
}
var fluffColor:Color = Color.WHITE

func _init():
	super._init()
	id = "SmallEar"

func generateFor(_gen:CharacterGenerator):
	super.generateFor(_gen)
	fluffColor = _gen.colors.fluff
	tassels = RNG.chance(50.0)
	tasselsColor = fluffColor
	
	pickPattern(pattern, _gen, TextureVariantType.EarPattern, "SmallEar")

func getName() -> String:
	return "Small ear"

func getScenePath(_slot:int) -> String:
	if(_slot == BodypartSlot.LeftEar):
		return "res://Mesh/Parts/Ear/SmallEar/small_ear_l.tscn"
	else:
		return "res://Mesh/Parts/Ear/SmallEar/small_ear_r.tscn"

func getSupportedSkinTypes() -> Dictionary:
	return {
		SkinType.Fur: true,
	}

func getOptions() -> Dictionary:
	var theOptions:Dictionary = super.getOptions()
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
			texSubType = "SmallEar",
			editors = [EDITOR_PART],
		}

	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Ear/SmallEar/Patterns/SmallManyPatterns.gd",
		
	]
