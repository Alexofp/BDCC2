extends BodypartHeadBase

var headLayers:Array = [
	{
		id = "HumanFeminineHead_Lips",
		r = Color("ff26009b"),
		g = Color(0.1484, 0.0058, 0.0058, 1.0),
		b = Color(1.0, 1.0, 1.0, 1.0),
	},
]

func _init():
	super._init()
	id = "HumanFeminineHead"
	skinType = SkinType.HumanSkin

func getName() -> String:
	return "Human Feminine head"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Head/HumanFeminine/my_human_head.tscn"

func getOptions() -> Dictionary:
	var theOptions := super.getOptions()
	theOptions["headLayers"] = {
			name = "Layers",
			type = "texVarLayerList",
			texType = TextureVariantType.HeadLayer,
			texSubType = "HumanFeminineHead",
			editors = [EDITOR_PART],
		}
	return theOptions

func getSupportedSkinTypes() -> Dictionary:
	return {
		SkinType.HumanSkin: true,
		SkinType.Fur: true,
	}


func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Head/HumanFeminine/HumanFemHeadLayersMany.gd",
	]
