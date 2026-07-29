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

func generateFor(_gen:CharacterGenerator):
	super.generateFor(_gen)
	generateSkinLayerMain(headLayers, _gen, TextureVariantType.HeadLayer, "HumanFeminineHead")

func registerForSpecies():
	addForSpecies("Human", ANY_GENDER, 1001.0) # 1001.0 means it will always win for hybrids

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
