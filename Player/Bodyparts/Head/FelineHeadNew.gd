extends BaseHeadBodypart

func _init():
	super._init()
	
	id = "FelineHeadNew"

func getVisibleName():
	return "Feline head (new)"

func getMeshPath() -> String:
	return "res://Mesh/Parts/Head/FelineHead/feline_head.tscn"

func getOptions() -> Dictionary:
	var result = {
		"cheekfluff": {
			"name": "Cheek fluff",
			"type": "checkbox",
			"default": false,
			"group": "Cheek fluff"
		},
		"fluffdown": {
			"name": "Cheek fluff form",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": "Cheek fluff"
		},
		"fluffshort": {
			"name": "Cheek fluff length",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": "Cheek fluff"
		},
		"fluffwide": {
			"name": "Cheek fluff wide",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": "Cheek fluff"
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
			"default": [
				{id="res://Mesh/Parts/Head/FelineHead/layers/nose.png",color=Color.LIGHT_PINK},
				{id="res://Mesh/Parts/Head/FelineHead/layers/EyesLipsOutline.png",color=Color.BLACK},
			],
			"customPossibleValues": {
				"res://Mesh/Parts/Head/FelineHead/layers/nose.png": {name="Nose"},
				"res://Mesh/Parts/Head/FelineHead/layers/EyesLipsOutline.png": {name="Eyes+Lips Outline"},
				"res://Mesh/Parts/Head/FelineHead/layers/EyesShadow.png": {name="Eyes Shadow"},
				"res://Mesh/Parts/Head/FelineHead/layers/shape1.png": {name="Shape 1"},
				"res://Mesh/Parts/Head/FelineHead/layers/shape2.png": {name="Shape 2", pattern=true},
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

