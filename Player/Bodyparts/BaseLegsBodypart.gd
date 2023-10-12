extends BaseBodypart
class_name BaseLegsBodypart
# Will probably merge with body

func getOptions() -> Dictionary:
	return {
		"someslider": {
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.5,
		},
	}

func getMeshScene() -> PackedScene:
	return load("res://Mesh/Parts/Legs/DigiLegs/digi_legs.tscn")

func getBodypartSlots():
	return {
	}
