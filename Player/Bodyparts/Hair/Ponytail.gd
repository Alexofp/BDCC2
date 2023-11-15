extends BaseHairBodypart

func _init():
	super._init()
	
	id = "PonytailHair"

func getVisibleName():
	return "Ponytail"

func getSkinOptions() -> Dictionary:
	return {
		"hue": {
			"name": "Hair hue",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"sat": {
			"name": "Hair saturation",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 2.0,
			"default": 1.0,
		},
		"value": {
			"name": "Hair value",
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 2.0,
			"default": 1.0,
		},
	}
