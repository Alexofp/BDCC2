extends BaseBodyBodypart

func _init():
	super._init()
	
	id = "FeminineBodyNew"

func getVisibleName():
	return "Feminine body NEW"

func getOptions() -> Dictionary:
	return {
		"breastsize": {
			"name": "Breast size",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"muscles": {
			"name": "Muscles",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"crotchwidth": {
			"name": "Crotch width",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"shoulderswidth": {
			"name": "Shoulders width",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"thickbutt": {
			"name": "Butt thickness",
			"type": "slider",
			"minvalue": -0.2,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"height": {
			"name": "Height",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": "Scaling parts",
		},
		"headsize": {
			"name": "Head size",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": "Scaling parts",
		},
		"tailsize": {
			"name": "Tail size",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": "Scaling parts",
		},
		"legstype": {
			"name": "Legs type",
			"type": "list",
			"default": "planti",
			"values": [
				["digi", "Digi-grade"],
				["planti", "Planti-grade"],
			],
		},
		"pussy": {
			"name": "Vagina",
			"type": "list",
			"default": "pussy",
			"values": [
				["pussy", "Normal vagina"],
				["nopussy", "No vagina"],
			],
		},
		
# Skin options
		"skinlayers": {
			"name": "Skin layers",
			"type": "layers",
			"default": [],
			"customPossibleValues": {
				"res://Mesh/Parts/Body/FeminineBodyNew/Layers/fur1.png": {name="Fur 1", pattern=true},
			},
			"menu": ["skin"],
		},
		"nipplehue": {
			"name": "Nipple hue",
			"type": "slider",
			"step": 0.01,
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": "Breasts",
			"menu": ["skin"],
		},
		"nipplesat": {
			"name": "Nipple saturation",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 2.0,
			"default": 1.0,
			"group": "Breasts",
			"menu": ["skin"],
		},
		"nipplevalue": {
			"name": "Nipple value",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 2.0,
			"default": 1.0,
			"group": "Breasts",
			"menu": ["skin"],
		},
		"nippletexture": {
			"name": "Nipples texture",
			"type": "texture",
			"values": getTextureVariantsByTypeAndSubType(TextureType.Nipples, TextureSubType.Generic),
			"default": "default",
			"group": "Breasts",
			"menu": ["skin"],
		},
		"genhue": {
			"name": "Genitals hue",
			"type": "slider",
			"step": 0.01,
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": "Genitals",
			"menu": ["skin"],
		},
		"gensat": {
			"name": "Genitals saturation",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 2.0,
			"default": 1.0,
			"group": "Genitals",
			"menu": ["skin"],
		},
		"genvalue": {
			"name": "Genitals value",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 2.0,
			"default": 1.0,
			"group": "Genitals",
			"menu": ["skin"],
		},
		"pubes": {
			"name": "Pubic hair",
			"type": "texture",
			"values": getTextureVariantsByTypeAndSubType(TextureType.PubicHair, TextureSubType.Generic),
			"default": "shaved",
			#"group": "Brows/lashes",
			"menu": ["skin"],
		},
		"muscletan": {
			"name": "Muscles tan",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"menu": ["skin"],
		},
	}

func getMeshPath() -> String:
	return "res://Mesh/Parts/Body/FeminineBodyNew/feminine_body.tscn"
