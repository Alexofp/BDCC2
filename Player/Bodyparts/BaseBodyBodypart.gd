extends BaseBodypart
class_name BaseBodyBodypart

func _init():
	super._init()
	bodypartType = BodypartType.Body

func getOptions() -> Dictionary:
	return {
		"breastsize": {
			"name": "Breast size",
			"type": "slider",
			"minvalue": -1.0,
			"maxvalue": 1.0,
			"default": 0.0,
		},
	}

func getSkeletonScene() -> PackedScene:
	return load("res://Mesh/Skeleton/Feminine/feminine_skeleton.tscn")

func getMeshPath() -> String:
	return "res://Mesh/Parts/Body/FeminineBody/feminine_body.tscn"

func getBodypartSlots():
	return {
		BodypartSlot.Head: true,
		BodypartSlot.Tail: true,
		#BodypartSlot.Legs: true,
	}
