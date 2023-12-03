extends BaseBodyBodypart

func _init():
	super._init()
	
	id = "MasculineBody"

func getVisibleName():
	return "Masculine body"

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
		"shoulderswidth": {
			"name": "Shoulders width",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 1.0,
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
			"default": "digi",
			"values": [
				["digi", "Digi-grade"],
				["planti", "Planti-grade"],
			],
		},
		"pussy": {
			"name": "Vagina",
			"type": "list",
			"default": "nopussy",
			"values": [
				["pussy", "Normal vagina"],
				["nopussy", "No vagina"],
			],
		},
	}

func getMeshPath() -> String:
	return "res://Mesh/Parts/Body/MasculineBody/masculine_body.tscn"
