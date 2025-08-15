extends BodypartHeadBase

var headLayers:Array = [
	{
		id="FelineHead_Snout",
		colorR = Color("ff9898"),
		colorG = Color.WHITE,
		colorB = Color.WHITE,
	}
]
var fluff:bool = true
var fluffDown:float = 0.0
var fluffWide:float = 0.0
var fluffShort:float = 0.0

func _init():
	super._init()
	id = "FelineHead"
	skinType = SkinType.Fur

func getName() -> String:
	return "Feline head"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Head/FelineHead/feline_head.tscn"

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
			texSubType = "FelineHead",
			editors = [EDITOR_PART],
		}
	theOptions["fluff"] = {
			name = "Cheek fluff",
			type = "bool",
			editors = [EDITOR_PART],
		}
	theOptions["fluffDown"] = {
			name = "Fluff down",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["fluffWide"] = {
			name = "Fluff spread",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["fluffShort"] = {
			name = "Fluff trim",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}

	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Head/FelineHead/FelineHeadLayersMany.gd",
	]
