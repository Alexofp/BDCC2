extends "res://Game/Character/Bodyparts/Head/HumanFeminineHead.gd"

var beard:Array = [""]

func _init():
	super._init()
	id = "HumanMasculineHead"
	
	brows["id"] = "Brow_Brow7"
	eyelashes["id"] = "Eyelashes_Eyelashes3"

func generateFor(_gen:CharacterGenerator):
	super.generateFor(_gen)
	
	brows["id"] = "Brow_Brow7"
	eyelashes["id"] = "Eyelashes_Eyelashes3"
	
	pickPiercings(beard, ["b1", "b2", "b3"], 70.0, [
		_gen.colors.hair, _gen.colors.hair, _gen.colors.hair, _gen.colors.hair
	])
	if(beard.size() <= 1 && RNG.chance(70.0)):
		beard = ["b4", Color("333333b8"), Color("333333b8"), Color("333333b8")]

func registerForSpecies():
	addForSpecies("Human", Gender.Male, 2001.0) # 1001.0 means it will always win for hybrids

func getName() -> String:
	return "Human Masculine head"

func getOptions() -> Dictionary:
	var theOptions := super.getOptions()
	theOptions["beard"] = {
		name = "Beard",
		type = "extraColored",
		values = [
			["", "No beard", 0],
			["b1", "Beard full", 1],
			["b2", "Beard goatee", 1],
			["b3", "Beard mustache", 1],
			["b4", "Beard shaved", 1],
		],
		editors = [EDITOR_PART],
		#editorZone = CharCreatorZone.Breasts,
	}
	return theOptions

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Head/HumanMasculine/my_human_head_masc.tscn"

func getTextureVariantsPaths() -> Array:
	return [
	]
