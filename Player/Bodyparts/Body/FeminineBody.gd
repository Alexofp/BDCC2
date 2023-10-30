extends BaseBodyBodypart

func _init():
	super._init()
	
	id = "FeminineBody"

func getVisibleName():
	return "Feminine body"

func getSkinOptions() -> Dictionary:
	return {
		"skinlayers": {
			"name": "Skin layers",
			"type": "layers",
			"default": [],
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
	}
