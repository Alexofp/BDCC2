extends BaseHeadBodypart

func _init():
	super._init()
	
	id = "FelineHead"

func getVisibleName():
	return "Feline head"

func getOptions() -> Dictionary:
	return {
		"muzzlesize": {
			"name": "Muzzle size",
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
		}
		result["eyesaturation"+eyeStuff[0]] = {
			"name": eyeStuff[1]+" saturation",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		}
		result["eyetype"+eyeStuff[0]] = {
			"name": eyeStuff[1]+" type",
			"type": "list",
			"default": "normal",
			"values": [
				["normal", "Normal"],
				["robot", "Robot"],
			]
		}
	return result
