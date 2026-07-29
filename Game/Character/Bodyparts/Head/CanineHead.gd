extends BodypartHeadBase

var headLayers:Array = [
]
var fluff:bool = true
var fluffSpiky:float = 0.0
var fluffWide:float = 0.0
var fluffLen:float = 0.0
var fluffThick:float = 0.0
var piercings:Array = [""]
var snout:Color = Color("9b9b9b")
var lines:Color = Color.BLACK

func _init():
	super._init()
	id = "CanineHead"
	skinType = SkinType.Fur

func generateFor(_gen:CharacterGenerator):
	super.generateFor(_gen)
	generateSkinLayerMain(headLayers, _gen, TextureVariantType.HeadLayer, "CanineHead")
	snout = _gen.colors.fur.color1
	snout.h -= randf_range(0.0, 0.01)
	snout.s = clampf(snout.s + randf_range(0.0, 0.2), 0.0, 1.0)
	snout.v = randf_range(0.0, 0.2)

func registerForSpecies():
	addForSpecies("Canine", ANY_GENDER, 1.0)

func getName() -> String:
	return "Canine head"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Head/CanineHead/canine_head.tscn"

func getSupportedSkinTypes() -> Dictionary:
	return {
		#SkinType.HumanSkin: true,
		SkinType.Fur: true,
	}

func getOptions() -> Dictionary:
	var theOptions:Dictionary = super.getOptions()
	theOptions["headLayers"] = {
			name = "Layers",
			type = "texVarLayerList",
			texType = TextureVariantType.HeadLayer,
			texSubType = "CanineHead",
			editors = [EDITOR_PART],
		}
	theOptions["snout"] = {
			name = "Snout color",
			type = "color",
			alpha = true,
			editors = [EDITOR_PART],
		}
	theOptions["lines"] = {
			name = "Liner color",
			type = "color",
			alpha = true,
			editors = [EDITOR_PART],
		}
	theOptions["fluff"] = {
			name = "Cheek fluff",
			type = "bool",
			editors = [EDITOR_PART],
		}
	theOptions["fluffSpiky"] = {
			name = "Fluff spiky",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["fluffWide"] = {
			name = "Fluff spread",
			type = "slider",
			min = -1.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["fluffLen"] = {
			name = "Fluff length",
			type = "slider",
			min = -1.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["fluffThick"] = {
			name = "Fluff thickness",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["piercings"] = {
			name = "Piercings",
			type = "extraColored",
			values = [
				["", "No piercings", 0],
				["p1", "Piercings 1", 2],
			],
			editors = [EDITOR_PART],
		}

	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Head/CanineHead/Textures/Layers/CanineHeadLayersMany.gd",
	]
