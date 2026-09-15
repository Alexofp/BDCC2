extends BodypartPenisBase

var penisScale:float = 1.0
var penisLenMod:float = 1.0
var penBallsDrop:float = 0.0
var penBallsScale:float = 1.0
var pattern:Dictionary = {
	id = "HumanPenis_Default",
	r = Color("a37272ff"),
	g = Color("954555"),
	b = Color("7814086c"),
}
#var shaftColor:Color = Color("954555")
var pubes:int = 0
var pubesColor:Color = Color("211e1e66")
var erection:float = 0.0

func _init():
	super._init()
	id = "HumanPenis"
	skinType = SkinType.Auto

func generateFor(_gen:CharacterGenerator):
	super.generateFor(_gen)
	#pubesColor = _gen.colors.fluff
	pubesColor = _gen.colors.hair
	var possiblePubes:Array[int] = [0]
	if(!_gen.species.has("Human") || _gen.species.size() > 1):
		possiblePubes = [2]
	if(_gen.species.has("Human")):
		possiblePubes.append(1)
	pubes = RNG.pick(possiblePubes)
	if(pubes == 2):
		pattern["id"] = "HumanPenis_Anthro"
	
	var theR:Color = _gen.colors.penis
	theR.h -= 0.03
	theR.s = clampf(theR.s*0.8, 0.0, 1.0)
	theR.v = clampf(theR.v*1.1, 0.0, 1.0)
	var theB:Color = _gen.colors.penis
	theB.h += 0.03
	theB.s = clampf(theR.s*1.3, 0.0, 1.0)
	theB.v = clampf(theR.v*0.9, 0.0, 1.0)
	#pattern["r"] = theR
	#pattern["g"] = _gen.colors.penis
	#pattern["b"] = theB
	#shaftColor = _gen.colors.penis

func getName() -> String:
	return "Human penis"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Penis/HumanPenis/HumanPenis.tscn"

func getSupportedSkinTypes() -> Dictionary:
	return {
		SkinType.Auto: true,
		SkinType.HumanSkin: true,
		SkinType.Fur: true,
	}

func getOptions() -> Dictionary:
	var theOptions:Dictionary = super.getOptions()
	#theOptions["shaftColor"] = {
			#name = "Shaft color",
			#type = "color",
			#editors = [EDITOR_PART],
		#}
	theOptions["erection"] = {
			name = "Erection",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_INTERACT],
		}
	theOptions["pattern"] = {
			name = "Pattern",
			type = "pattern",
			texType = TextureVariantType.PenisPattern,
			texSubType = "HumanPenis",
			editors = [EDITOR_PART],
		}
	theOptions["penisScale"] = {
			name = "Size",
			type = "slider",
			min = 0.5,
			max = 1.5,
			editors = [EDITOR_PART],
		}
	theOptions["penisLenMod"] = {
			name = "Length",
			type = "slider",
			min = 0.2,
			max = 2.0,
			editors = [EDITOR_PART],
		}
	theOptions["penBallsDrop"] = {
			name = "Balls position",
			type = "slider",
			min = -0.02,
			max = 0.02,
			editors = [EDITOR_PART],
		}
	theOptions["penBallsScale"] = {
			name = "Balls scale",
			type = "slider",
			min = 0.0,
			max = 2.0,
			editors = [EDITOR_PART],
		}
	theOptions["pubes"] = {
			name = "Pubic hair",
			type = "selector",
			values = [
				[0, "None"],
				[1, "Pubic hair"],
				[2, "Fluff"],
			],
			editors = [EDITOR_PART],
		}
	theOptions["pubesColor"] = {
			name = "Pubic hair color",
			type = "color",
			alpha = true,
			editors = [EDITOR_PART],
		}
		
	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Penis/HumanPenis/Patterns/HumanPenisTexVariantsMany.gd",
	]
