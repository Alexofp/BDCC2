extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "InmateShorts"
	
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/InmateShorts/InmateShorts.tscn",
	}
