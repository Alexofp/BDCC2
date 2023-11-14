extends BaseBodypart
class_name BaseHairBodypart

func getOptions() -> Dictionary:
	return {
		"someslider": {
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.5,
		},
	}

func getMeshPath() -> String:
	return "res://Mesh/Parts/Hair/Ponytail/ponytail.tscn"

func getBodypartSlots():
	return {
	}
