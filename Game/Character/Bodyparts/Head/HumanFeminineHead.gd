extends BodypartHeadBase

var headLayers:Array = [
	{
		id = "HumanFeminineHead_Lips",
		r = Color("ff2600a3"),
		g = Color("4a01017e"),
		b = Color("940a0a"),
	},
	{
		id = "HumanFeminineHead_EyeShadow",
		r = Color("000000d4"),
		g = Color("3b0000a0"),
		b = Color("b31414fb"),
	},
]
var earsElf:float = 0.0
var lipsBig:float = 0.0
var earsHide:float = 0.0
var jawWide:float = 0.0
var fangs:float = 0.0

func _init():
	super._init()
	id = "HumanFeminineHead"
	skinType = SkinType.HumanSkin

func generateFor(_gen:CharacterGenerator):
	super.generateFor(_gen)
	generateSkinLayerMain(headLayers, _gen, TextureVariantType.HeadLayer, "HumanFeminineHead")
	
	if(_gen.species.size() == 1):
		earsElf = clampf(randf_range(0.7, 1.1), 0.0, 1.0) if RNG.chance(20.0) else 0.0
	var fangsChance:float = 20.0 if _gen.species.size() <= 1 else 95.0
	fangs = clampf(randf_range(0.7, 1.2), 0.0, 1.0) if RNG.chance(fangsChance) else 0.0
	lipsBig = randf_range(0.0, 1.0)
	jawWide = randf_range(0.0, 1.0)
	
	var theLipsColor:Color = Color("ff2600ff")
	theLipsColor.s = maxf(_gen.colors.skin.s*randf_range(2.0, 3.0), 0.3)
	theLipsColor.v = _gen.colors.skin.v
	theLipsColor.h = RNG.pick([theLipsColor.h, _gen.colors.hair.h, _gen.colors.eyeL.color1.h])
	#theLipsColor.h = theLipsColor.h
	theLipsColor.a = randf_range(0.6, 1.0)
	headLayers[0]["r"] = theLipsColor
	headLayers[0]["b"] = ColorUtils.shadow(theLipsColor, 0.5)

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
	theOptions["earsElf"] = {
			name = "Elf ears",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["earsHide"] = {
			name = "Hide ears",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["jawWide"] = {
			name = "Wide jaw",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["lipsBig"] = {
			name = "Lips fullness",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["fangs"] = {
			name = "Fangs",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Mouth,
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
