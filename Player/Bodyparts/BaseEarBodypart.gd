extends BaseBodypart
class_name BaseEarBodypart

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
	return preload("res://Mesh/Parts/Ear/CatEar/cat_ear.tscn")

func getBodypartSlots():
	return {
	}
