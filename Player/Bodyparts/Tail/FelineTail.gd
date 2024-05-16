extends BaseTailBodypart

func _init():
	super._init()
	
	id = "FelineTail"

func getVisibleName():
	return "Feline tail"

func getOptions() -> Dictionary:
	return {
		"tailthick": {
			"name": "Thickness",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"tailspirtal": {
			"name": "Spiral",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		"tailbat": {
			"name": "End thickness",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
		
# Skin options
		"tailpattern": {
			"name": "Tail pattern",
			"type": "patternAndColors",
			"default": ["nopattern", Color.RED, Color.GREEN, Color.BLUE],
			"menu": ["skin"],
		},
		"patternscale": {
			"name": "Pattern scale",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
			"menu": ["skin"],
		},
	}


func getMeshPath() -> String:
	return "res://Mesh/Parts/Tail/FelineTail/feline_tail.tscn"

func getBodypartSlots():
	return {
	}
