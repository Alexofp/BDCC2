extends BodypartExtra

func _init():
	super._init()
	id = "FelineHeadPiercingChain"
	supportedBodypartIDs = ["FelineHeadNew"]
	attachToSlot = "Rig"

func getVisibleName():
	return "Chain piercings"

func getMeshPath() -> String:
	return "res://Mesh/Parts/Head/FelineHead/Extras/PiercingChain/piercing_chain.tscn"

func getOptions() -> Dictionary:
	var result = {
		"color": {
			"name": "Color",
			"type": "color",
			"default": Color.WHITE,
		},
		"leftChain": {
			"name": "Left chain",
			"type": "checkbox",
			"default": true,
		},
		"rightChain": {
			"name": "Right chain",
			"type": "checkbox",
			"default": false,
		},
	}
	return result
