extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "NippleClampsWeight"
	
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/NippleClampsWeight/nipple_clamps_weight.tscn",
	}
