extends BaseHeadBodypart

func _init():
	super._init()
	
	id = "MaleHumanHead"

func getVisibleName():
	return "Human head (Masculine)"

func getMeshPath() -> String:
	return "res://Mesh/Parts/Head/MaleHumanHead/male_human_head.tscn"

func getOptions() -> Dictionary:
	return {
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
	}

func checkSkinOptionChanged(_valueID, _oldValue, _newValue):
	if(_valueID == "sameeyes" && _oldValue != _newValue):
		recalculateOptionsCache()

func getSkinOptions() -> Dictionary:
	var result = {
		"age": {
			"name": "Age",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.5,
		},
		"mouthcolor": {
			"name": "Mouth",
			"type": "color",
			"default": Color.WHITE,
		},
		"tonguecolor": {
			"name": "Tongue",
			"type": "color",
			"default": Color.WHITE,
		},
		"nosecolor": {
			"name": "Nose",
			"type": "color",
			"default": Color.WHITE,
		},
		"brows": {
			"name": "Brows",
			"type": "texture",
			"values": getTextureVariantsByTypeAndSubType(TextureType.Brows, TextureSubType.Generic),
			"default": "brow1",
			"group": "Brows/lashes",
		},
		"eyelashes": {
			"name": "Eyelashes",
			"type": "texture",
			"values": getTextureVariantsByTypeAndSubType(TextureType.Eyelashes, TextureSubType.Generic),
			"default": "eyelash1",
			"group": "Brows/lashes",
		},
		"sameeyes": {
			"name": "Same eyes",
			"type": "checkbox",
			"default": true,
		},
	}
	
	var eyesStuff = [
		["", "Eye"]
	]
	if(!getSkinOptionValue("sameeyes", true)):
		eyesStuff = [
			["", "Left eye"],
			["_right", "Right eye"],
		]
	
	for eyeStuff in eyesStuff:
		result["eyehue"+eyeStuff[0]] = {
			"name": eyeStuff[1]+" hue",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": eyeStuff[1],
		}
		result["eyesaturation"+eyeStuff[0]] = {
			"name": eyeStuff[1]+" saturation",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": eyeStuff[1],
		}
		result["eyetype"+eyeStuff[0]] = {
			"name": eyeStuff[1]+" type",
			"type": "texture",
			"default": "normal",
			"values": getTextureVariantsByTypeAndSubType(TextureType.Eyes, TextureSubType.Generic),
			"group": eyeStuff[1],
		}
	return result
