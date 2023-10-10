extends BaseBodypart
class_name BaseBodyBodypart

func getOptions() -> Dictionary:
	return {
		"breastsize": {
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.5,
		},
		"thickbutt": {
			"type": "slider",
			"minvalue": 0.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
	}

func getSkeletonScene() -> PackedScene:
	return preload("res://Mesh/Skeleton/Feminine/feminine_skeleton.tscn")

func getMeshScene() -> PackedScene:
	return preload("res://Mesh/Parts/Body/FeminineBody/feminine_body.tscn")

func getBodypartSlots():
	return {
		BodypartSlot.Head: true,
	}
