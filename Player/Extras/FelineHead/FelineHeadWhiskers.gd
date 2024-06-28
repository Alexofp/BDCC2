extends BodypartExtra

func _init():
	super._init()
	id = "FelineHeadWhiskers"
	supportedBodypartIDs = ["FelineHeadNew"]
	attachToSlot = "Rig"

func getVisibleName():
	return "Whiskers"

func getMeshPath() -> String:
	return "res://Mesh/Parts/Head/FelineHead/Extras/Whiskers/feline_whiskers.tscn"

func getOptions() -> Dictionary:
	var result = {
		"color": {
			"name": "Color",
			"type": "color",
			"default": Color.BLACK,
		},
		"length": {
			"name": "Length",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"drop": {
			"name": "Drop",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
	}
	return result
