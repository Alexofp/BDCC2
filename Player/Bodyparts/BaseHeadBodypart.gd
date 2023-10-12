extends BaseBodypart
class_name BaseHeadBodypart

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
	return load("res://Mesh/Parts/Head/CatHead/cat_head.tscn")

func getBodypartSlots():
	return {
		BodypartSlot.LeftEar: true,
		BodypartSlot.RightEar: true,
	}
