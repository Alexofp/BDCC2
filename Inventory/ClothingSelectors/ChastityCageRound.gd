extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "ChastityCageRound"
	
	bodypartSlot = BodypartSlot.Penis
	sceneByBodypartID = {
		"HumanPenis": "res://Mesh/Clothing/ChastityCages/CageRound.tscn",
		"CaninePenis": "res://Mesh/Clothing/ChastityCages/CageRound.tscn",
	}
