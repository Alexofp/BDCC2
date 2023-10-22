extends BaseBodypart
class_name BaseTailBodypart

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
	return load("res://Mesh/Parts/Tail/FelineTail/feline_tail.tscn")

func getBodypartSlots():
	return {
	}
