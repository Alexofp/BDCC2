extends BodypartHeadBase

var headLayers:Array = [
	{
		id="FelineHead_Snout",
		colorR = Color("ff9898"),
		colorG = Color.WHITE,
		colorB = Color.WHITE,
	}
]

func _init():
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
			editors = [EDITOR_SKIN],
		}

	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Head/FelineHead/FelineHeadLayersMany.gd",
	]
