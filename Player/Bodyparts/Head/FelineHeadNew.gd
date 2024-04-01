extends BaseHeadBodypart

func _init():
	super._init()
	
	id = "FelineHeadNew"

func getVisibleName():
	return "Feline head (new)"

func getMeshPath() -> String:
	return "res://Mesh/Parts/Head/FelineHead/feline_head.tscn"

func getOptions() -> Dictionary:
	return {
		"cheekfluff": {
			"name": "Cheek fluff",
			"type": "checkbox",
			"default": false,
		},
		"fluffpointy": {
			"name": "Cheek fluff form",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
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
		"muzzlewidth": {
			"name": "Muzzle width",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"nosebridge": {
			"name": "Nose bridge",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"nosebig": {
			"name": "Nose size",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"eyessize": {
			"name": "Eyes size",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"eyesspacing": {
			"name": "Eyes spacing",
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
		"skinlayers": {
			"name": "Skin layers",
			"type": "layers",
			"default": [{id="res://Mesh/Parts/Head/CanineHead/skinlayers/nose.png",color=Color.LIGHT_GRAY}],
			"customPossibleValues": {
				"res://Mesh/Parts/Head/CanineHead/skinlayers/nose.png": {name="Nose"},
				"res://Mesh/Parts/Head/CanineHead/skinlayers/foxmark.png": {name="Fox mark"},
				"res://Mesh/Parts/Head/CanineHead/skinlayers/tophead.png": {name="Shape 1"},
			}
		},
		"mouthcolor": {
			"name": "Mouth",
			"type": "color",
			"default": Color.LIGHT_PINK,
			"group": "Mouth",
		},
		"tonguecolor": {
			"name": "Tongue",
			"type": "color",
			"default": Color.LIGHT_PINK,
			"group": "Mouth",
		},
		"teethcolor": {
			"name": "Teeth",
			"type": "color",
			"default": Color.WHITE,
			"group": "Mouth",
		},
		"mouthrough": {
			"name": "Mouth roughness",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 1.0,
			"group": "Mouth",
		},
		"mouthspec": {
			"name": "Mouth specular",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.1,
			"group": "Mouth",
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
			"step": 0.01,
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
