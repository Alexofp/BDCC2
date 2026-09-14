extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "ChastityCageFlat"
	
	bodypartSlot = BodypartSlot.Penis
	sceneByBodypartID = {
		"HumanPenis": "res://Mesh/Clothing/ChastityCages/CageFlat.tscn",
		"CaninePenis": "res://Mesh/Clothing/ChastityCages/CageFlat.tscn",
	}
