extends BaseHeadBodypart

func _init():
	super._init()
	
	id = "FelineHead"

func getVisibleName():
	return "Feline head"

func getSkinOptions() -> Dictionary:
	return {
		"eyehue": {
			"name": "Eye hue",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"eyesaturation": {
			"name": "Eye saturation",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"eyetype": {
			"name": "Eye type",
			"type": "list",
			"default": "normal",
			"values": [
				["normal", "Normal"],
				["robot", "Robot"],
			]
		},
	}
