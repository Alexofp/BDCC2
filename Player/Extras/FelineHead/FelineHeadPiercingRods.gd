extends BodypartExtra

func _init():
	super._init()
	id = "FelineHeadPiercingRods"
	supportedBodypartIDs = ["FelineHeadNew"]
	attachToSlot = "Rig"

func getVisibleName():
	return "Piercings rods"

func getMeshPath() -> String:
	return "res://Mesh/Parts/Head/FelineHead/Extras/PiercingRods/piercing_rods.tscn"

func getOptions() -> Dictionary:
	var result = {
		"color": {
			"name": "Color",
			"type": "color",
			"default": Color.WHITE,
		},
		"rod1": {
			"name": "Row 1",
			"type": "checkbox",
			"default": true,
		},
		"rod2": {
			"name": "Row 2",
			"type": "checkbox",
			"default": true,
		},
		"rod3": {
			"name": "Row 3",
			"type": "checkbox",
			"default": true,
		},
		"rod4": {
			"name": "Row 4",
			"type": "checkbox",
			"default": true,
		},
		"rod5": {
			"name": "Row 5",
			"type": "checkbox",
			"default": true,
		},
	}
	return result
