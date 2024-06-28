extends BaseHeadBodypart

func _init():
	super._init()
	
	id = "FemaleHumanHead"

func getVisibleName():
	return "Human head (Feminine)"

func getMeshPath() -> String:
	return "res://Mesh/Parts/Head/FemaleHumanHead/female_human_head.tscn"

func getOptions() -> Dictionary:
	var result = {
		"muzzlesize": {
			"name": "Muzzle size",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"muzzlelen": {
			"name": "Muzzle length",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"nosebridge": {
			"name": "Nose bridge",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		
# Skin options
		"mouthcolor": {
			"name": "Mouth",
			"type": "color",
			"default": Color.WHITE,
			"menu": ["skin"],
		},
		"tonguecolor": {
			"name": "Tongue",
			"type": "color",
			"default": Color.WHITE,
			"menu": ["skin"],
		},
		"nosecolor": {
			"name": "Nose",
			"type": "color",
			"default": Color.WHITE,
			"menu": ["skin"],
		},
		"brows": {
			"name": "Brows",
			"type": "texture",
			"values": getTextureVariantsByTypeAndSubType(TextureType.Brows, TextureSubType.Generic),
			"default": "brow1",
			"group": "Brows/lashes",
			"menu": ["skin"],
		},
		"eyelashes": {
			"name": "Eyelashes",
			"type": "texture",
			"values": getTextureVariantsByTypeAndSubType(TextureType.Eyelashes, TextureSubType.Generic),
			"default": "eyelash1",
			"group": "Brows/lashes",
			"menu": ["skin"],
		},
		"sameeyes": {
			"name": "Same eyes",
			"type": "checkbox",
			"default": true,
			"menu": ["skin"],
		},
	}
	
	var eyesStuff = [
		["", "Eye"]
	]
	if(!getOptionValue("sameeyes", true)):
		eyesStuff = [
			["", "Left eye"],
			["_right", "Right eye"],
		]
	
	for eyeStuff in eyesStuff:
		result["eyehue"+eyeStuff[0]] = {
			"name": eyeStuff[1]+" hue",
			"type": "slider",
			"step": 0.01,
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": eyeStuff[1],
			"menu": ["skin"],
		}
		result["eyesaturation"+eyeStuff[0]] = {
			"name": eyeStuff[1]+" saturation",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": eyeStuff[1],
			"menu": ["skin"],
		}
		result["eyetype"+eyeStuff[0]] = {
			"name": eyeStuff[1]+" type",
			"type": "texture",
			"default": "normal",
			"values": getTextureVariantsByTypeAndSubType(TextureType.Eyes, TextureSubType.Generic),
			"group": eyeStuff[1],
			"menu": ["skin"],
		}
	return result

func checkOptionChanged(_valueID, _oldValue, _newValue):
	if(_valueID == "sameeyes" && _oldValue != _newValue):
		recalculateOptionsCache()

func getPartTags() -> Dictionary:
	return {
		PartTag.Head_HumanNeck: true,
	}
