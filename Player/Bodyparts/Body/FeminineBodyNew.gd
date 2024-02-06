extends BaseBodyBodypart

func _init():
	super._init()
	
	id = "FeminineBodyNew"

func getVisibleName():
	return "Feminine body NEW"

func getSkinOptions() -> Dictionary:
	return {
		"skinlayers": {
			"name": "Skin layers",
			"type": "layers",
			"default": [],
		},
		"nipplehue": {
			"name": "Nipple hue",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": "Breasts",
		},
		"nipplesat": {
			"name": "Nipple saturation",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 2.0,
			"default": 1.0,
			"group": "Breasts",
		},
		"nipplevalue": {
			"name": "Nipple value",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 2.0,
			"default": 1.0,
			"group": "Breasts",
		},
		"nippletexture": {
			"name": "Nipples texture",
			"type": "texture",
			"values": getTextureVariantsByTypeAndSubType(TextureType.Nipples, TextureSubType.Generic),
			"default": "default",
			"group": "Breasts",
		},
		"genhue": {
			"name": "Genitals hue",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"group": "Genitals",
		},
		"gensat": {
			"name": "Genitals saturation",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 2.0,
			"default": 1.0,
			"group": "Genitals",
		},
		"genvalue": {
			"name": "Genitals value",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 2.0,
			"default": 1.0,
			"group": "Genitals",
		},
		"pubes": {
			"name": "Pubic hair",
			"type": "texture",
			"values": getTextureVariantsByTypeAndSubType(TextureType.PubicHair, TextureSubType.Generic),
			"default": "shaved",
			#"group": "Brows/lashes",
		},
		"muscletan": {
			"name": "Muscles tan",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"skinroughness": {
			"name": "Skin roughness",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 1.0,
		},
		"skinspecular": {
			"name": "Skin specular",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.5,
		},
	}

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
	}

func getMeshPath() -> String:
	return "res://Mesh/Parts/Body/FeminineBodyNew/feminine_body.tscn"
