extends BaseHeadBodypart

func _init():
	super._init()
	
	id = "CanineHead"

func getVisibleName():
	return "Canine head"

func getMeshPath() -> String:
	return "res://Mesh/Parts/Head/CanineHead/canine_head.tscn"

func getOptions() -> Dictionary:
	var result = {
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
		
# Skin options
		"skinlayers": {
			"name": "Skin layers",
			"type": "layers",
			"default": [{id="res://Mesh/Parts/Head/CanineHead/skinlayers/nose.png",color=Color.LIGHT_GRAY}],
			"customPossibleValues": {
				"res://Mesh/Parts/Head/CanineHead/skinlayers/nose.png": {name="Nose"},
				"res://Mesh/Parts/Head/CanineHead/skinlayers/foxmark.png": {name="Fox mark"},
				"res://Mesh/Parts/Head/CanineHead/skinlayers/tophead.png": {name="Shape 1"},
			},
			"menu": ["skin"],
		},
		"mouthcolor": {
			"name": "Mouth",
			"type": "color",
			"default": Color.LIGHT_PINK,
			"group": "Mouth",
			"menu": ["skin"],
		},
		"tonguecolor": {
			"name": "Tongue",
			"type": "color",
			"default": Color.LIGHT_PINK,
			"group": "Mouth",
			"menu": ["skin"],
		},
		"teethcolor": {
			"name": "Teeth",
			"type": "color",
			"default": Color.WHITE,
			"group": "Mouth",
			"menu": ["skin"],
		},
		"mouthrough": {
			"name": "Mouth roughness",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 1.0,
			"group": "Mouth",
			"menu": ["skin"],
		},
		"mouthspec": {
			"name": "Mouth specular",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.1,
			"group": "Mouth",
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
