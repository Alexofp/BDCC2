extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "InmateCollar"
	
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/InmateCollar/inmate_collar.tscn",
	}
