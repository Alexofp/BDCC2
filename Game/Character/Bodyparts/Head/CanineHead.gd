extends BodypartHeadBase

var headLayers:Array = [
	{
		id="CanineHead_Snout",
		colorR = Color("9b9b9b"),
		colorG = Color.WHITE,
		colorB = Color.WHITE,
	},
	{
		id="CanineHead_Lines",
		colorR = Color.BLACK,
		colorG = Color.WHITE,
		colorB = Color.WHITE,
	},
]
var fluff:bool = true
var fluffSpiky:float = 0.0
var fluffWide:float = 0.0
var fluffLen:float = 0.0
var fluffThick:float = 0.0

func _init():
	super._init()
	id = "CanineHead"
	skinType = SkinType.Fur

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

	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Head/CanineHead/Textures/Layers/CanineHeadLayersMany.gd",
	]
