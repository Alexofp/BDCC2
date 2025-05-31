extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "PlainPanties"
	
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/PlainPanties/plain_panties_fem.tscn",
	}
